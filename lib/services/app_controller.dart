import 'jobs_repository.dart';

import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../data/catalog.dart';
import '../data/course_catalog.dart';
import 'local_memory_service.dart';
import 'recommendation_engine.dart';
import 'cloud_service.dart';

class AppController extends ChangeNotifier {
  final local = LocalMemoryService();
  final engine = RecommendationEngine();
  final CloudService? cloud;
  UserProfile profile = UserProfile();
  bool loading = true;
  final JobsRepository jobsRepository;
  List<JobItem> availableJobs = [];
  bool jobsLoading = false;
  String? jobsError;
  bool get demoJobs => jobsRepository.isDemo;
  AppController({this.cloud, JobsRepository? jobsRepository})
      : jobsRepository = jobsRepository ?? JobsRepository();

  Future<void> refreshJobs() async {
    if (jobsLoading) return;
    jobsLoading = true;
    jobsError = null;
    notifyListeners();
    try {
      availableJobs = await jobsRepository.load();
    } catch (_) {
      jobsError = 'Não foi possível atualizar as vagas. Tente novamente.';
    } finally {
      jobsLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectJob(JobItem job) async {
    profile.targetRole = job.title;
    profile.targetJobId = job.id;
    profile.targetRequirements = Map.of(job.requirements);
    addEvent('target_role_changed', {'role': job.title, 'jobId': job.id});
    await persist();
  }

  Future<void> init() async {
    profile = await local.load();
    profile.journeyStage = engine.stage(profile);
    loading = false;
    notifyListeners();
    await refreshJobs();
  }

  Future<void> persist() async {
    profile.journeyStage = engine.stage(profile);
    await local.save(profile);
    if (cloud?.signedIn == true) {
      try {
        await cloud!.save(profile);
      } catch (_) {}
    }
    notifyListeners();
  }

  void addEvent(String type, [Map<String, dynamic>? data]) => profile.events
      .add({'type': type, 'at': DateTime.now().toIso8601String(), ...?(data)});
  double compatibility() => engine.compatibility(profile);
  Map<String, double> gaps() => engine.skillGaps(profile);
  List<CourseItem> recommendedCourses() {
    final g = gaps().keys.toSet();
    final list = courseCatalog
        .where(
          (c) =>
              g.contains(c.skill) && !profile.completedCourses.contains(c.id),
        )
        .toList();
    return list.isNotEmpty
        ? list
        : courseCatalog
            .where((c) => !profile.completedCourses.contains(c.id))
            .toList();
  }

  double stageProgress(String id) {
    final p = profile;
    switch (id) {
      case 'discovery':
        return ([
                  p.targetRole.isNotEmpty,
                  p.viewedJobs.length >= 2,
                  p.savedJobs.isNotEmpty,
                  p.skills.isNotEmpty,
                ].where((x) => x).length /
                4)
            .clamp(0, 1);
      case 'training':
        final req = engine.requirements(p);
        final met =
            req.entries.where((e) => (p.skills[e.key] ?? 0) >= e.value).length;
        return req.isEmpty
            ? (p.targetJobId.isEmpty ? 1 : 0)
            : (met / req.length).clamp(0, 1);
      case 'resume':
        return ([
                  p.professionalSummary.isNotEmpty,
                  p.education.isNotEmpty,
                  p.completedCourses.isNotEmpty,
                  p.skills.isNotEmpty,
                  p.targetRole.isNotEmpty,
                ].where((x) => x).length /
                5)
            .clamp(0, 1);
      case 'search':
        if (p.hired) return 1;
        if (p.interviews.isNotEmpty) return .8;
        if (p.applications.length >= 3) return .65;
        if (p.applications.isNotEmpty) return .45;
        if (p.savedJobs.isNotEmpty) return .2;
        return 0;
      case 'entry':
        if (!p.hired) return 0;
        return p.currentRole.isNotEmpty ? 1 : .7;
      case 'development':
        if (!p.hired) return 0;
        return ((p.completedCourses.length + p.projects.length).clamp(0, 4) /
            4);
    }
    return 0;
  }

  double overallProgress() {
    const ids = [
      'discovery',
      'training',
      'resume',
      'search',
      'entry',
      'development',
    ];
    return ids.map(stageProgress).reduce((a, b) => a + b) / ids.length;
  }

  Future<void> saveJob(String title) async {
    if (!profile.savedJobs.contains(title)) profile.savedJobs.add(title);
    addEvent('job_saved', {'role': title});
    await persist();
  }

  Future<void> viewJob(String title) async {
    if (!profile.viewedJobs.contains(title)) profile.viewedJobs.add(title);
    addEvent('job_viewed', {'role': title});
    await persist();
  }

  Future<void> setTargetRole(String title) async {
    profile.targetJobId = '';
    profile.targetRequirements = {};
    profile.targetRole = title;
    addEvent('target_role_changed', {'role': title});
    await persist();
  }

  Future<void> completeCourse(CourseItem course) async {
    if (!profile.completedCourses.contains(course.id))
      profile.completedCourses.add(course.id);
    if (!profile.certificates.contains(course.title))
      profile.certificates.add(course.title);
    profile.skills[course.skill] =
        ((profile.skills[course.skill] ?? 0) + .18).clamp(0, 1);
    addEvent('course_completed', {
      'courseId': course.id,
      'skill': course.skill,
    });
    await persist();
  }

  Future<void> addCertificate(String value) async {
    final v = value.trim();
    if (v.isEmpty) return;
    if (!profile.certificates.contains(v)) profile.certificates.add(v);
    addEvent('certificate_added', {'title': v});
    await persist();
  }

  Future<void> saveJourneyActivity(String stage, String reflection, String plan,
      List<String> completed) async {
    final oldNotes = Map<String, String>.of(profile.journeyNotes);
    final oldActivities = List<String>.of(profile.journeyActivities);
    profile.journeyNotes['$stage.reflection'] = reflection.trim();
    profile.journeyNotes['$stage.plan'] = plan.trim();
    profile.journeyActivities.removeWhere((key) => key.startsWith('$stage.'));
    profile.journeyActivities
        .addAll(completed.where((key) => key.startsWith('$stage.')).toSet());
    try {
      await persist();
    } catch (_) {
      profile.journeyNotes = oldNotes;
      profile.journeyActivities = oldActivities;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateResume({
    required String summary,
    required String education,
  }) async {
    profile.professionalSummary = summary.trim();
    profile.education = education.trim();
    addEvent('resume_updated');
    await persist();
  }
}

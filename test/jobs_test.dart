import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:primeiro_passo/data/catalog.dart';
import 'package:primeiro_passo/screens/jobs_screen.dart';
import 'package:primeiro_passo/services/app_controller.dart';
import 'package:primeiro_passo/services/jobs_repository.dart';

class FakeJobs extends JobsRepository {
  FakeJobs() : super(baseUrl: 'https://example.com');
  bool fail = false;
  @override
  Future<List<JobItem>> load() async {
    if (fail) throw StateError('offline');
    return [
      JobItem.fromMap({
        'id': '1',
        'title': 'Assistente',
        'company': 'Empresa A',
        'requirements': {'Excel': 0.8}
      }),
      JobItem.fromMap({
        'id': '2',
        'title': 'Assistente',
        'company': 'Empresa B',
        'requirements': {'Excel': 0.4}
      }),
    ];
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('IDs distinguish equal titles and requirements survive reload',
      () async {
    final controller = AppController(jobsRepository: FakeJobs());
    await controller.init();
    final a = controller.availableJobs[0], b = controller.availableJobs[1];
    expect(a.storageKey, isNot(b.storageKey));
    await controller.saveJob(a.storageKey);
    await controller.selectJob(b);
    final restored = AppController(jobsRepository: FakeJobs());
    await restored.init();
    expect(restored.profile.targetJobId, '2');
    expect(restored.engine.requirements(restored.profile)['Excel'], 0.4);
    expect(restored.profile.savedJobs, ['api:1']);
    controller.dispose();
    restored.dispose();
  });

  test('failed refresh preserves last results and exposes error', () async {
    final repository = FakeJobs();
    final controller = AppController(jobsRepository: repository);
    await controller.init();
    repository.fail = true;
    await controller.refreshJobs();
    expect(controller.availableJobs.length, 2);
    expect(controller.jobsError, isNotNull);
    expect(controller.jobsLoading, false);
    controller.dispose();
  });

  test('unsafe URL and invalid requirements are rejected', () {
    expect(
        () => JobItem.fromMap({
              'id': 'x',
              'title': 'A',
              'company': 'B',
              'application_url': 'javascript:alert(1)'
            }),
        throwsFormatException);
    expect(
        () => JobItem.fromMap({
              'id': 'x',
              'title': 'A',
              'company': 'B',
              'requirements': {'Excel': 2}
            }),
        throwsFormatException);
  });

  testWidgets('standalone jobs has Material and search by company',
      (tester) async {
    final controller = AppController(jobsRepository: FakeJobs());
    await controller.init();
    await tester.pumpWidget(ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(home: JobsScreen(standalone: true))));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.enterText(find.byType(TextField), 'Empresa B');
    await tester.pumpAndSettle();
    expect(
        find.byWidgetPredicate(
            (widget) => widget is Text && widget.data == 'Empresa B'),
        findsOneWidget);
    expect(find.text('Empresa A'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}

import 'package:flutter/material.dart';
import '../data/journey_topics.dart';
import 'journey_topic_screen.dart';
import 'discovery_screen.dart';
import 'training_hub_screen.dart';
import 'resume_builder_screen.dart';

/// One destination for each stage, shared by Home and Journey.
void openJourneyStage(BuildContext context, String id) {
  final Widget screen = switch (id) {
    'discovery' => const DiscoveryScreen(),
    'training' => const TrainingHubScreen(),
    'resume' => const ResumeBuilderScreen(),
    'search' => const JourneyTopicScreen(topic: searchTopic),
    'entry' => const JourneyTopicScreen(topic: entryTopic),
    'development' => const JourneyTopicScreen(topic: developmentTopic),
    _ => throw ArgumentError.value(id, 'id', 'Etapa desconhecida'),
  };
  Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}

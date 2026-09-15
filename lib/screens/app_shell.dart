import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_controller.dart';
import '../widgets/ui.dart';
import 'home_screen.dart';
import 'journey_screen.dart';
import 'assistant_screen.dart';
import 'jobs_screen.dart';
import 'profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  void go(int value) => setState(() => index = value);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    if (controller.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: purple)),
      );
    }

    final pages = [
      HomeScreen(onNavigate: go),
      const JourneyScreen(),
      const AssistantScreen(),
      const JobsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: IndexedStack(index: index, children: pages),
              ),
              _BottomNav(index: index, onChanged: go),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _BottomNav({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded, 'Início'),
      (Icons.menu_book_rounded, 'Trilhas'),
      (Icons.chat_bubble_outline_rounded, 'Assistente'),
      (Icons.search_rounded, 'Vagas'),
      (Icons.person_outline_rounded, 'Perfil'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: line)),
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(6, 7, 6, 8),
      child: Row(
        children: List.generate(items.length, (i) {
          final selected = index == i;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onChanged(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[i].$1,
                      color: selected ? purple : muted,
                      size: 24,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      items[i].$2,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w500,
                        color: selected ? purple : muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

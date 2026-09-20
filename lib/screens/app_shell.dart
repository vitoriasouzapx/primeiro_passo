import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_controller.dart';
import '../widgets/ui.dart';
import 'home_screen.dart';
import 'journey_screen.dart';
import 'resume_overview_screen.dart';
import '../widgets/brand.dart';
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
      const JobsScreen(),
      const ResumeOverviewScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: bg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760 && constraints.maxHeight >= 480;
          final content = Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1040),
              color: Colors.white,
              child: Column(
                children: [
                  Expanded(
                    child: IndexedStack(index: index, children: pages),
                  ),
                  if (!wide)
                    SafeArea(
                      top: false,
                      child: _BottomNav(index: index, onChanged: go),
                    ),
                ],
              ),
            ),
          );
          if (!wide) return content;
          return Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  selectedIndex: index,
                  onDestinationSelected: go,
                  extended: constraints.maxWidth >= 1180,
                  labelType: constraints.maxWidth >= 1180
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all,
                  leading: const Padding(
                    padding: EdgeInsets.all(16),
                    child: BrandLogo(compact: true),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_rounded),
                      label: Text('Início'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.menu_book_rounded),
                      label: Text('Jornada'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.work_outline_rounded),
                      label: Text('Vagas'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.description_outlined),
                      label: Text('Currículo'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline_rounded),
                      label: Text('Perfil'),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: content),
            ],
          );
        },
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
      (Icons.explore_outlined, 'Jornada'),
      (Icons.work_outline_rounded, 'Vagas'),
      (Icons.description_outlined, 'Currículo'),
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
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w500,
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

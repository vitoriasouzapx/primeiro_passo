import 'package:flutter/material.dart';

const Color purple = Color(0xFF3548FF);
const Color purpleDark = Color(0xFF18244A);
const Color purpleSoft = Color(0xFFEEF0FF);
const Color blue = Color(0xFF4986FF);
const Color blueSoft = Color(0xFFEAF4FF);
const Color green = Color(0xFF1597A6);
const Color greenSoft = Color(0xFFE7FAF3);
const Color orange = Color(0xFFF68B45);
const Color orangeSoft = Color(0xFFFFF0E6);
const Color pink = Color(0xFFE95684);
const Color pinkSoft = Color(0xFFFFEAF1);
const Color ink = Color(0xFF101A33);
const Color muted = Color(0xFF626F91);
const Color bg = Color(0xFFF5F7FC);
const Color line = Color(0xFFE8ECF6);

class AppSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const AppSurface({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: bg,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 960),
          color: Colors.white,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: ink,
                    letterSpacing: -0.7,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: muted,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = Colors.white,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(22)),
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: Border.all(color: line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1B2B50),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return content;
    return InkWell(borderRadius: borderRadius, onTap: onTap, child: content);
  }
}

class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final double size;
  const IconBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.background,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * .3),
      ),
      child: Icon(icon, color: color, size: size * .52),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final IconData? icon;
  const SectionTitle({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: purple, size: 21),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: ink,
              ),
            ),
          ),
          if (action != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                action!,
                style: const TextStyle(
                  color: purple,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ProgressLine extends StatelessWidget {
  final double value;
  final Color color;
  const ProgressLine({super.key, required this.value, this.color = purple});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: 8,
        color: color,
        backgroundColor: const Color(0xFFE6EAF3),
      ),
    );
  }
}

class MiniStatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String value;
  final String label;
  const MiniStatCard({
    super.key,
    required this.icon,
    required this.color,
    required this.background,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, color: color, background: background, size: 37),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: ink,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: muted,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color background;
  final VoidCallback? onTap;
  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.background,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, color: color, background: background, size: 43),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20, color: muted),
        ],
      ),
    );
  }
}

class PageScaffold extends StatelessWidget {
  final Widget child;
  const PageScaffold({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: bg,
        body: AppSurface(child: child),
      );
}

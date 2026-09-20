import 'package:flutter/material.dart';
import '../widgets/ui.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Stack(children: [
                  const Positioned.fill(child: CustomPaint(painter: _Waves())),
                  SafeArea(
                      child: LayoutBuilder(
                          builder: (context, bounds) => SingleChildScrollView(
                              child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      minHeight: bounds.maxHeight),
                                  child: Padding(
                                      padding: const EdgeInsets.all(28),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const SizedBox(height: 32),
                                            Column(children: [
                                              Image.asset(
                                                  'assets/images/marca.png',
                                                  width: 165,
                                                  height: 165),
                                              const SizedBox(height: 12),
                                              const FittedBox(
                                                  child: Text.rich(
                                                      TextSpan(children: [
                                                        TextSpan(
                                                            text: 'Primeiro ',
                                                            style: TextStyle(
                                                                color: ink)),
                                                        TextSpan(
                                                            text: 'Passo',
                                                            style: TextStyle(
                                                                color: purple))
                                                      ]),
                                                      style: TextStyle(
                                                          fontSize: 36,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          letterSpacing:
                                                              -1.5))),
                                              const SizedBox(height: 8),
                                              const Text(
                                                  'Do primeiro passo ao primeiro emprego.',
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      TextStyle(color: muted))
                                            ]),
                                            const SizedBox(height: 48),
                                            Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  const SizedBox(height: 28),
                                                  FilledButton(
                                                      onPressed: () =>
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (_) =>
                                                                      const LoginScreen())),
                                                      child: const Text(
                                                          'Começar')),
                                                  const SizedBox(height: 12)
                                                ]),
                                          ]))))))
                ]))),
      );
}

class _Waves extends CustomPainter {
  const _Waves();
  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(bounds, Paint()..color = Colors.white);
    final path = Path()
      ..moveTo(0, size.height * .9)
      ..cubicTo(size.width * .5, size.height * .91, size.width * .57,
          size.height * .64, size.width, size.height * .65)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
        path,
        Paint()
          ..shader = const LinearGradient(
                  colors: [Color(0xFFC9DDFF), Color(0xFF4986FF)])
              .createShader(bounds));
    final second = Path()
      ..moveTo(0, size.height)
      ..cubicTo(size.width * .5, size.height * .99, size.width * .55,
          size.height * .8, size.width, size.height * .79)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
        second,
        Paint()
          ..shader = const LinearGradient(
                  colors: [Color(0xFFBDAAFF), Color(0xFF8053FF)])
              .createShader(bounds));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

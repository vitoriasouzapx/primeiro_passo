import 'package:flutter/material.dart';
import 'ui.dart';

class BrandLogo extends StatelessWidget {
  final bool compact;
  const BrandLogo({super.key, this.compact = false});
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Image.asset('assets/images/marca.png',
            width: compact ? 40 : 54, height: compact ? 40 : 54),
        if (!compact) ...[
          const SizedBox(width: 8),
          const Flexible(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                Text.rich(
                    TextSpan(children: [
                      TextSpan(text: 'Primeiro ', style: TextStyle(color: ink)),
                      TextSpan(text: 'Passo', style: TextStyle(color: purple))
                    ]),
                    style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1)),
                Text('Do primeiro passo ao primeiro emprego.',
                    style: TextStyle(fontSize: 10, color: muted)),
              ])),
        ],
      ]);
}

import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../models/story.dart';
import '../theme/app_theme.dart';
import 'filter_chip_pill.dart';

class MediumFilterRow extends StatelessWidget {
  const MediumFilterRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<Medium?> options;
  final Medium? selected;
  final ValueChanged<Medium?> onSelected;

  static const double _gap = 7;

  double _textWidth(String text, TextStyle style, TextScaler scaler) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(
      context,
    ).style.merge(Theme.of(context).textTheme.bodyMedium);
    final scaler = MediaQuery.textScalerOf(context);
    final labels = [for (final o in options) o?.label ?? 'All'];
    final textWidths = [
      for (final label in labels) _textWidth(label, style, scaler),
    ];

    return SizedBox(
      height: 35,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final available = math.max(
            0.0,
            constraints.maxWidth - AppTheme.spaceMd * 2,
          );
          final gaps = _gap * (options.length - 1);
          final natural = textWidths.fold<double>(
            0,
            (sum, w) => sum + w + FilterChipPill.basePadding * 2,
          );
          final extra = available - natural - gaps;
          final fits = extra >= 0;
          final padding =
              FilterChipPill.basePadding +
              (fits ? extra / options.length / 2 : 0);

          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: fits
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: available),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = 0; i < options.length; i++) ...[
                      if (i > 0) const SizedBox(width: _gap),
                      FilterChipPill(
                        label: labels[i],
                        selected: selected == options[i],
                        horizontalPadding: padding,
                        onTap: () => onSelected(options[i]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

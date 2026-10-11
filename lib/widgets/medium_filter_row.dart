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
  static const double _minPadding = 4;

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
    final theme = Theme.of(context);
    final style = DefaultTextStyle.of(
      context,
    ).style.merge(theme.textTheme.bodyMedium);
    final scaler = MediaQuery.textScalerOf(context);
    final labels = [for (final o in options) o?.label ?? 'All'];
    final textWidths = [
      for (final label in labels) _textWidth(label, style, scaler),
    ];

    return SizedBox(
      height: 35,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final available = constraints.maxWidth;
            final count = options.length;
            final gaps = _gap * (count - 1);
            final natural = textWidths.fold<double>(
              0,
              (sum, w) => sum + w + FilterChipPill.basePadding * 2,
            );

            final extra = available - natural - gaps;
            final padding = (FilterChipPill.basePadding + extra / count / 2)
                .clamp(_minPadding, double.infinity);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < count; i++) ...[
                  if (i > 0) const SizedBox(width: _gap),
                  Expanded(
                    flex: ((textWidths[i] + padding * 2) * 100).round(),
                    child: FilterChipPill(
                      label: labels[i],
                      selected: selected == options[i],
                      horizontalPadding: padding,
                      onTap: () => onSelected(options[i]),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

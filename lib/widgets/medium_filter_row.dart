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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: LayoutBuilder(
        builder: (context, constraints) {
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
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth - AppTheme.spaceMd * 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = 0; i < options.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppTheme.spaceSm),
                      FilterChipPill(
                        label: options[i]?.label ?? 'All',
                        selected: selected == options[i],
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

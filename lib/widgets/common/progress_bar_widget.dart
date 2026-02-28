import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/layout.dart';

class ProgressBarWidget extends StatelessWidget {
  final double value; // 0.0 ~ 1.0
  final Color? color;
  final double height;
  final bool showLabel;

  const ProgressBarWidget({
    super.key,
    required this.value,
    this.color,
    this.height = 8.0,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppLayout.radiusCircle),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            backgroundColor: AppColors.surfaceAltColor(context),
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColors.primary,
            ),
            minHeight: height,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Text(
            '${(value * 100).toInt()}%',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondaryColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

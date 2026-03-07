import 'package:flutter/material.dart';
import 'package:tripmates/app/theme/app_colors.dart';

/// Star rating widget for reviews
class StarRatingWidget extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;
  final bool interactive;
  final ValueChanged<double>? onRatingChanged;
  final Color activeColor;
  final Color inactiveColor;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.size = 24.0,
    this.interactive = false,
    this.onRatingChanged,
    this.activeColor = AppColors.primary,
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        final starValue = index + 1;
        final isFullStar = rating >= starValue;
        final isHalfStar = rating >= starValue - 0.5 && rating < starValue;

        return GestureDetector(
          onTap: interactive
              ? () => onRatingChanged?.call(starValue.toDouble())
              : null,
          child: Icon(
            isFullStar
                ? Icons.star
                : isHalfStar
                ? Icons.star_half
                : Icons.star_border,
            size: size,
            color: (isFullStar || isHalfStar) ? activeColor : inactiveColor,
          ),
        );
      }),
    );
  }
}

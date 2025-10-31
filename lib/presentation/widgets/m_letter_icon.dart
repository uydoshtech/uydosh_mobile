import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";

class MLetterIcon extends StatelessWidget {
  const MLetterIcon({
    super.key,
    this.size = 24.0,
    this.color = AppColors.genderMale,
    this.fontWeight = FontWeight.bold,
  });

  final double size;
  final Color color;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: size * 0.12),
      ),
      child: Center(
        child: Text(
          "M",
          style: TextStyle(
            color: color,
            fontSize: size * 0.55,
            fontWeight: fontWeight,
            fontFamily: "Arial",
          ),
        ),
      ),
    );
  }
}

// Alternative version with just the letter (no background)
class MLetterIconSimple extends StatelessWidget {
  const MLetterIconSimple({
    super.key,
    this.size = 24.0,
    this.color = AppColors.genderMale,
    this.fontWeight = FontWeight.bold,
  });

  final double size;
  final Color color;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      "M",
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: fontWeight,
        fontFamily: "Arial",
      ),
    );
  }
}

// Circular version with background
class MLetterIconCircular extends StatelessWidget {
  const MLetterIconCircular({
    super.key,
    this.size = 24.0,
    this.color = AppColors.genderMale,
    this.fontWeight = FontWeight.bold,
  });

  final double size;
  final Color color;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(
          "M",
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: size * 0.6,
            fontWeight: fontWeight,
            fontFamily: "Arial",
          ),
        ),
      ),
    );
  }
}

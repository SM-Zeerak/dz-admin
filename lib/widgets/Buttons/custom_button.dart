import 'package:dz_admin_panel/core/color_cons.dart';
import 'package:dz_admin_panel/core/textStyle_cons.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final double borderRadius;
  final double elevation;
  final double fontSize;
  final double height;
  final double width;
  final FontWeight? fontWeight;
  final Color? borderColor;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color = const Color.fromARGB(255, 6, 11, 27),
    this.textColor = Colors.white,
    this.borderRadius = 10,
    this.elevation = 0,
    this.fontSize = 16.0,
    this.height = 45,
    this.width = double.infinity,
    this.fontWeight,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: Size(width, height),
        minimumSize:Size(width, height),
        padding: EdgeInsets.zero,
        foregroundColor: textColor,
        backgroundColor: color,
        elevation: elevation,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: borderColor ?? Colors.transparent),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Text(
        text,
        style: TextStylesCons.custom(
            fontSize: fontSize, color: textColor, fontWeight: fontWeight ?? FontWeight.normal),
      ),
    );
  }
}

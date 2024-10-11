import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final Color color;
  final double borderRadius;
  final double padding;
  final double? height;
  final double? width;
  final Widget? decoration;
  final IconData? Icon1;
  final Color? Textcolor;
  final String? Logoimage;

  CustomButton({
    required this.onTap,
    required this.text,
    this.color = Colors.blue,
    this.borderRadius = 8.0,
    this.padding = 16.0,
    this.width = 250,
    this.height = 50,
    this.decoration,
    this.Icon1,
    this.Textcolor = Colors.black,
    this.Logoimage,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Logoimage == null
                ? SizedBox()
                : Image.asset(
                    Logoimage!,
                    height: 28,
                  ),
            Icon1 == null
                ? const SizedBox()
                : Icon(
                    Icon1!,
                    color: Colors.black,
                  ),
            Text(
              text,
              style: TextStyle(
                color: Textcolor!,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? text;
  final double? height;
  final prefix;
  final suffixicon;
  final double? width;
  final double? textSize;
  final Color? textColor;
  final String? validateText;
  CustomTextField({
    required this.labelText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.text,
    this.prefix,
    this.suffixicon,
    this.height,
    this.width,
    this.textSize = 14,
    this.textColor = const Color.fromARGB(158, 0, 0, 0),
    this.validateText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text == null
              ? const SizedBox()
              : Text(
                  text!,
                  style: TextStyle(
                      fontSize: textSize!,
                      fontWeight: FontWeight.bold,
                      color: textColor!),
                ),
          const SizedBox(height: 12),
          SizedBox(
            height: height,
            width: width,
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              cursorColor: Colors.black,
              style: const TextStyle(color: Color(0xFF000000)),
              decoration: InputDecoration(
                prefixIcon: prefix,
                suffixIcon: suffixicon,
                labelText: labelText,
                filled: true,
                fillColor: const Color.fromARGB(78, 255, 255, 255),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return validateText;
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/color_manger.dart';

class CustomTextFormField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextStyle? hintStyle;
  final Color? fillColor;
  final Color? cursorColor;
  final bool obscureText;
  final double? width;
  final double? height;
  const CustomTextFormField({
    super.key,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.hintStyle,
    this.fillColor,
    this.cursorColor,
    this.width,
    this.height,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool isSecure = true;
  @override
  Widget build(BuildContext context) {
    //final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: widget.width,
      height: widget.height,
      alignment: Alignment.center,
      child: TextFormField(
        style: const TextStyle(color: Colors.white),
        cursorColor:  ColorManager.primaryColor,
        controller: widget.controller,
        obscureText: widget.obscureText ? isSecure : false,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          // Adds a suffix icon if the field requires obscuring (e.g., a password field)
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: isSecure
                      ? Icon(Icons.visibility_off_outlined,
                          color: const Color(0xFFC5C6D0).withOpacity(0.5),
                          size: 30)
                      : const Icon(Icons.visibility_outlined,
                          color: ColorManager.primaryColor, size: 30),
                  // Toggles the visibility of the text input when the icon is pressed
                  onPressed: () {
                    setState(() {
                      isSecure = !isSecure;
                    });
                  },
                )
              : null,
          filled: true,
          fillColor:
              widget.fillColor ?? const Color(0xFF202A44).withOpacity(0.6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(
                color: ColorManager.primaryColor,
              )),
          errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(
                color: Colors.red,
              )),
          hintText: widget.hintText,
          hintStyle: widget.hintStyle ??
              TextStyle(
                  color: const Color(0xFFC5C6D0).withOpacity(0.5),
                  fontSize: 18),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter Your ${widget.hintText}';
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }
}

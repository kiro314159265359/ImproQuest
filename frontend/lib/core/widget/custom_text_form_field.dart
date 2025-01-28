import 'package:flutter/material.dart';
import '../theme/color_manger.dart';
import '../theme/text_style.dart';
import 'package:intl/intl.dart';

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
  final bool showCalendarIcon;
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
    this.showCalendarIcon = false,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool isSecure = true;
  DateTime? birthdate;

  Future<void> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: birthdate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && mounted) {
      setState(() {
        birthdate = pickedDate;
        widget.controller.text = DateFormat('MM/dd/yyyy').format(birthdate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: widget.width,
      height: widget.height,
      alignment: Alignment.center,
      child: TextFormField(
        style: TextStyles.styleSemiBold(context,
            fontSize: 18, color: ColorManager.whiteColor),
        cursorColor: ColorManager.primaryColor,
        controller: widget.controller,
        obscureText: widget.obscureText ? isSecure : false,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          suffixIcon: widget.showCalendarIcon
              ? IconButton(
                  icon: Icon(
                    Icons.calendar_today,
                    color: ColorManager.lightGrey.withOpacity(0.5),
                    size: 30,
                  ),
                  onPressed: () {
                    selectDate(context);
                  },
                )
              : widget.obscureText
                  ? IconButton(
                      icon: isSecure
                          ? Icon(Icons.visibility_off_outlined,
                              color: ColorManager.lightGrey.withOpacity(0.5),
                              size: 30)
                          : const Icon(Icons.visibility_outlined,
                              color: ColorManager.primaryColor, size: 30),
                      onPressed: () {
                        setState(() {
                          isSecure = !isSecure;
                        });
                      },
                    )
                  : null,
          filled: true,
          fillColor: widget.fillColor ?? ColorManager.gunmetal.withOpacity(0.6),
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
          errorStyle: TextStyles.styleSemiBold(context,
              fontSize: 12, color: Colors.red),
          hintText: widget.hintText,
          hintStyle: widget.hintStyle ??
              TextStyles.styleSemiBold(context,
                  fontSize: 18, color: ColorManager.lightGrey.withOpacity(0.5)),
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

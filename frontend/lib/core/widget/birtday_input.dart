import 'package:flutter/material.dart';
import 'custom_text_form_field.dart';

class BirthdayInput extends StatelessWidget {
  final TextEditingController dayController;
  final TextEditingController monthController;
  final TextEditingController yearController;

  const BirthdayInput({
    super.key,
    required this.dayController,
    required this.monthController,
    required this.yearController,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Day Field
        CustomTextFormField(
          hintText: "DD",
          controller: dayController,
          width: screenWidth * 0.161,
          height: 35,
          keyboardType: TextInputType.number,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
        // Separator
        Text(
          '/',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
        ),
        // Month Field
        CustomTextFormField(
          hintText: "MM",
          controller: monthController,
          width: screenWidth * 0.162,
          height: 35,
          keyboardType: TextInputType.number,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
        Text(
          '/',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
        ),
        // Year Field
        CustomTextFormField(
          hintText: "YYYY",
          controller: yearController,
          width: screenWidth * 0.199,
          height: 35,
          keyboardType: TextInputType.number,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
      ],
    );
  }
}

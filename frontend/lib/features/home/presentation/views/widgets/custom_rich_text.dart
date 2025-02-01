import 'package:flutter/material.dart';

class CustomRichText extends StatefulWidget {
  final String text1;
  final TextStyle? textStyle1;
  final String text2;
  final TextStyle? textStyle2;
  const CustomRichText(
      {super.key,
      required this.text1,
      required this.text2,
      this.textStyle1,
      this.textStyle2});

  @override
  State<CustomRichText> createState() => _CustomRichTextState();
}

class _CustomRichTextState extends State<CustomRichText> {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: widget.text1,
        style: widget.textStyle1,
        children: <TextSpan>[
          TextSpan(
            text: widget.text2,
            style: widget.textStyle2,
          ),
        ],
      ),
    );
  }
}

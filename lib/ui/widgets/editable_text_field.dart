import 'package:flutter/material.dart';

class EditableText extends StatelessWidget {
  final String text;
  final bool isEdit;
  final Function(String) onSubmitted;
  final TextStyle? textStyle;
  final TextAlign textAlign;
  final TextEditingController _textFieldController = TextEditingController();
  final FocusNode myFocusNode = FocusNode();

  EditableText({
    required this.text,
    required this.isEdit,
    required this.onSubmitted,
    this.textStyle,
    this.textAlign = TextAlign.start,
  });

  InputDecoration _decoration() {
    return InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 3.0),
      isDense: true,
      filled: isEdit,
      fillColor: Colors.white,
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    _textFieldController.text = text;
    if (isEdit) myFocusNode.requestFocus();
    return TextField(
      textAlign: textAlign,
      controller: _textFieldController,
      focusNode: myFocusNode,
      enabled: isEdit,
      // onChanged: (newText) => onSubmitted(newText),
      onSubmitted: (newText) => onSubmitted(newText),
      style: textStyle,
      decoration: _decoration(),
      enableInteractiveSelection: true,
    );
  }
}

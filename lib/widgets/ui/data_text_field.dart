import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DataTextField extends StatelessWidget {
  final TextEditingController controller;
  final double width;
  final bool isNumber;
  final bool readOnly;
  final String label;

  const DataTextField(
      {super.key,
      required this.controller,
      this.label = '',
      this.width = 100,
      this.isNumber = true,
      this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: !readOnly,
      textAlign: TextAlign.start,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : null,
      inputFormatters: isNumber
          ? <TextInputFormatter>[
              FilteringTextInputFormatter.allow(
                  RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
              TextInputFormatter.withFunction(
                (oldValue, newValue) => newValue.copyWith(
                  text: newValue.text.replaceAll('.', '.'),
                ),
              ),
            ]
          : null,
      readOnly: readOnly,
      controller: controller,
      decoration: InputDecoration(
          label: Text(
            label,
          ),
          labelStyle: const TextStyle(color: Colors.black38),
          floatingLabelStyle: const TextStyle(color: Colors.black87),
          border: const OutlineInputBorder(
              borderSide: BorderSide(
                width: 1,
                style: BorderStyle.none,
              ),
              borderRadius: BorderRadius.all(Radius.circular(4))),
          filled: true,
          fillColor: const Color.fromARGB(244, 251, 251, 251)),
    );
  }
}

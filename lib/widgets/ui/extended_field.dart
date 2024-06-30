import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExtendedField extends StatelessWidget {
  final TextEditingController controller;
  final double width;
  final bool isNumber;
  final bool readOnly;
  final String label;

  const ExtendedField(
      {super.key,
      required this.controller,
      this.label = '',
      this.width = 100,
      this.isNumber = false,
      this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.only(bottom: 6, right: 6),
      child: SizedBox(
          // height: 60,
          width: 560,
          child: TextFormField(
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
                floatingLabelStyle: TextStyle(color: Colors.black87),
                border: const OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1,
                      style: BorderStyle.none,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(4))),
                filled: true,
                fillColor: const Color.fromARGB(244, 251, 251, 251)),
          )),
    );
  }
}

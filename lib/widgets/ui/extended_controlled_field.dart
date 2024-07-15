import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExtendedControlledField extends StatefulWidget {
  final double width;
  final bool isNumber;
  final bool readOnly;
  final String label;
  final String? initialValue;
  final void Function(String) onChanged;

  const ExtendedControlledField(
      {super.key,
      this.label = '',
      this.width = 100,
      this.initialValue,
      this.isNumber = false,
      required this.onChanged,
      this.readOnly = false});

  @override
  State<ExtendedControlledField> createState() =>
      _ExtendedControlledFieldState();
}

class _ExtendedControlledFieldState extends State<ExtendedControlledField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.text = widget.initialValue ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.only(bottom: 6, right: 6),
      child: SizedBox(
          // height: 60,
          width: 560,
          child: TextFormField(
            enabled: !widget.readOnly,
            textAlign: TextAlign.start,
            keyboardType: widget.isNumber
                ? const TextInputType.numberWithOptions(decimal: true)
                : null,
            inputFormatters: widget.isNumber
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
            readOnly: widget.readOnly,
            controller: _controller,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
                label: Text(
                  widget.label,
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

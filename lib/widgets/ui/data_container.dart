import 'package:flutter/material.dart';

class DataContainer extends StatelessWidget {
  const DataContainer({
    Key? key,
    required this.value,
  }) : super(key: key);

  final num value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      height: 50,
      decoration: BoxDecoration(
          border: const Border(
            top: BorderSide(color: Colors.black12),
            left: BorderSide(color: Colors.black12),
            right: BorderSide(color: Colors.black12),
            bottom: BorderSide(color: Colors.black12),
          ),
          color: const Color.fromARGB(255, 248, 248, 248),
          borderRadius: BorderRadius.circular(6)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value.toStringAsPrecision(4),
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    ));
  }
}

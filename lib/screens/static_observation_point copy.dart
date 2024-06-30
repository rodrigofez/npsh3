import 'package:flutter/material.dart';
import 'package:npsh3/models/observation_point.dart';
import 'package:npsh3/widgets/ui/data_container.dart';

class StaticObservationPointRow extends StatefulWidget {
  final ObservationPoint point;

  const StaticObservationPointRow({super.key, required this.point});

  @override
  State<StaticObservationPointRow> createState() =>
      _StaticObservationPointRowState();
}

class _StaticObservationPointRowState extends State<StaticObservationPointRow> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DataContainer(value: widget.point.porcentajeAperturaVs),
        const SizedBox(
          width: 8,
        ),
        DataContainer(value: widget.point.qInicial),
        const SizedBox(
          width: 8,
        ),
        DataContainer(value: widget.point.hTeorico),
        const SizedBox(
          width: 8,
        ),
        DataContainer(value: widget.point.presionEntrada),
        const SizedBox(
          width: 8,
        ),
        DataContainer(value: widget.point.presionSalida),
        const SizedBox(
          width: 8,
        ),
        DataContainer(value: widget.point.hExperimental),
        const SizedBox(
          width: 8,
        ),
        DataContainer(value: widget.point.deltaH),
      ],
    );
  }
}

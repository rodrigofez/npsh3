import 'package:flutter/material.dart';
import 'package:npsh3/models/observation_point.dart';
import 'package:npsh3/providers/npsh.dart';
import 'package:npsh3/widgets/ui/data_container.dart';
import 'package:npsh3/widgets/ui/data_field.dart';
import 'package:npsh3/widgets/ui/data_text_field.dart';
import 'package:provider/provider.dart';

class ObservationPointRow extends StatefulWidget {
  final ObservationPoint point;
  final int observationIndex;

  const ObservationPointRow(
      {super.key, required this.point, required this.observationIndex});

  @override
  State<ObservationPointRow> createState() => _ObservationPointRowState();
}

class _ObservationPointRowState extends State<ObservationPointRow> {
  late TextEditingController porcentajeAperturaController;
  late TextEditingController presionEntradaController;
  late TextEditingController presionSalidaController;
  late TextEditingController qController;
  late TextEditingController hTeoricoController;
  late TextEditingController hExperimentalController;
  late TextEditingController deltaHController;

  @override
  void initState() {
    super.initState();

    porcentajeAperturaController = TextEditingController(
        text: widget.point.porcentajeAperturaVs.toString());

    presionEntradaController =
        TextEditingController(text: widget.point.presionEntrada.toString());
    presionSalidaController =
        TextEditingController(text: widget.point.presionSalida.toString());
    qController = TextEditingController(text: widget.point.qInicial.toString());
    hTeoricoController =
        TextEditingController(text: widget.point.hTeorico.toString());
    hExperimentalController =
        TextEditingController(text: widget.point.hTeorico.toString());
    deltaHController =
        TextEditingController(text: widget.point.deltaH.toString());

    // Start listening to changes.
    presionEntradaController.addListener(_updatePresionEntrada);
    presionSalidaController.addListener(_updatePresionSalida);
    qController.addListener(_updateQ);
  }

  @override
  void didUpdateWidget(covariant ObservationPointRow oldWidget) {
    deltaHController =
        TextEditingController(text: widget.point.deltaH.toString());
    super.didUpdateWidget(oldWidget);
    hExperimentalController =
        TextEditingController(text: widget.point.hExperimental.toString());
    hTeoricoController =
        TextEditingController(text: widget.point.hTeorico.toString());
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _updateQInicial listener.
    presionEntradaController.dispose();
    presionSalidaController.dispose();
    qController.dispose();

    super.dispose();
  }

  void _updateQ() {
    print('gets gere');
    if (qController.text.isEmpty) return;
    Provider.of<NpshProvider>(context, listen: false).updateQObservationPoint(
        id: widget.point.id,
        index: widget.observationIndex,
        newQ: double.parse(qController.text));
  }

  void _updatePresionEntrada() {
    if (presionEntradaController.text.isEmpty) return;
    Provider.of<NpshProvider>(context, listen: false)
        .updatePresionEntradaObservationPoint(
            id: widget.point.id,
            index: widget.observationIndex,
            pEntrada: double.parse(presionEntradaController.text));
  }

  void _updatePresionSalida() {
    if (presionSalidaController.text.isEmpty) return;

    Provider.of<NpshProvider>(context, listen: false)
        .updatePresionSalidaObservationPoint(
            id: widget.point.id,
            index: widget.observationIndex,
            pSalida: double.parse(presionSalidaController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: Row(
        children: [
          Expanded(
            child: DataTextField(
              controller: porcentajeAperturaController,
              readOnly: true,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: DataTextField(
              controller: qController,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: DataTextField(
              controller: hTeoricoController,
              readOnly: true,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(child: DataTextField(controller: presionEntradaController)),
          const SizedBox(
            width: 8,
          ),
          Expanded(child: DataTextField(controller: presionSalidaController)),
          const SizedBox(
            width: 8,
          ),
          Expanded(
              child: DataTextField(
            controller: hExperimentalController,
            readOnly: true,
          )),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: DataTextField(
              controller: deltaHController,
              readOnly: true,
            ),
          ),
        ],
      ),
    );
  }
}

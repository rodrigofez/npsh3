import 'package:flutter/material.dart';
import 'package:npsh3/models/point.dart';
import 'package:npsh3/providers/npsh.dart';
import 'package:npsh3/widgets/ui/data_text_field.dart';
import 'package:provider/provider.dart';

class PointRow extends StatefulWidget {
  final Point point;

  const PointRow({super.key, required this.point});

  @override
  State<PointRow> createState() => _PointRowState();
}

class _PointRowState extends State<PointRow> {
  late TextEditingController presionEntradaController;
  late TextEditingController presionSalidaController;
  late TextEditingController qController;
  late TextEditingController hNetaController;
  late TextEditingController porcentajeAperturaController;

  @override
  void initState() {
    super.initState();

    presionEntradaController =
        TextEditingController(text: widget.point.presionEntrada.toString());
    presionSalidaController =
        TextEditingController(text: widget.point.presionSalida.toString());
    qController = TextEditingController(text: widget.point.qInicial.toString());
    hNetaController =
        TextEditingController(text: widget.point.hNeta.toString());
    porcentajeAperturaController =
        TextEditingController(text: widget.point.porcentajeApertura.toString());

    presionEntradaController.addListener(_updatePresionEntrada);
    presionSalidaController.addListener(_updatePresionSalida);
    qController.addListener(_updateQ);
  }

  @override
  void didUpdateWidget(covariant PointRow oldWidget) {
    hNetaController =
        TextEditingController(text: widget.point.hNeta.toString());
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    presionEntradaController.dispose();
    presionSalidaController.dispose();
    qController.dispose();
    hNetaController.dispose();
    porcentajeAperturaController.dispose();

    super.dispose();
  }

  void _updateQ() {
    Provider.of<NpshProvider>(context, listen: false).updateQ(
        id: widget.point.id,
        newQ: qController.text.isEmpty ? 0 : double.parse(qController.text));
  }

  void _updatePresionEntrada() {
    if (presionEntradaController.text.isEmpty) return;
    Provider.of<NpshProvider>(context, listen: false).updatePresionEntrada(
        id: widget.point.id,
        newPresionEntrada: presionEntradaController.text.isEmpty
            ? 0
            : double.parse(presionEntradaController.text));
  }

  void _updatePresionSalida() {
    Provider.of<NpshProvider>(context, listen: false).updatePresionSalida(
        id: widget.point.id,
        newPresionSalida: presionSalidaController.text.isEmpty
            ? 0
            : double.parse(presionSalidaController.text));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
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
            Expanded(child: DataTextField(controller: qController)),
            const SizedBox(
              width: 8,
            ),
            Expanded(
                child: DataTextField(controller: presionEntradaController)),
            const SizedBox(
              width: 8,
            ),
            Expanded(child: DataTextField(controller: presionSalidaController)),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: DataTextField(
                controller: hNetaController,
                readOnly: true,
              ),
            ),
          ],
        ),
      );
    });
  }
}

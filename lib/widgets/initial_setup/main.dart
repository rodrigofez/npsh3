import 'package:flutter/material.dart';
import 'package:npsh3/providers/npsh.dart';
import 'package:npsh3/widgets/ui/extended_controlled_field.dart';
import 'package:npsh3/widgets/ui/extended_field.dart';
import 'package:provider/provider.dart';

class InitialSetup extends StatefulWidget {
  const InitialSetup({super.key});

  @override
  State<StatefulWidget> createState() {
    return _InitialSetupState();
  }
}

class _InitialSetupState extends State<InitialSetup> {
  late TextEditingController marcaController;
  late TextEditingController serieController;
  late TextEditingController potenciaController;
  late TextEditingController temperaturaController;
  late TextEditingController patmosfericaController;
  late TextEditingController densidadController;
  late TextEditingController pvaporController;

  void _updateMarca() {
    if (marcaController.text.isEmpty) return;
    Provider.of<NpshProvider>(context, listen: false)
        .updateMarca(newMarca: marcaController.text);
  }

  void _updateSerie() {
    if (serieController.text.isEmpty) return;
    Provider.of<NpshProvider>(context, listen: false)
        .updateSerie(newSerie: serieController.text);
  }

  void _updatePotencia() {
    if (potenciaController.text.isEmpty) return;
    Provider.of<NpshProvider>(context, listen: false)
        .updatePotencia(newPotencia: double.parse(potenciaController.text));
  }

  void _updateTemperatura() {
    if (temperaturaController.text.isEmpty) return;
    Provider.of<NpshProvider>(context, listen: false).updateTemperatura(
        newTemperatura: double.parse(temperaturaController.text));

    setState(() {
      pvaporController.text = Provider.of<NpshProvider>(context, listen: false)
          .pvapor
          .toStringAsPrecision(3);
    });
  }

  void _updatePAtmosferica() {
    if (patmosfericaController.text.isEmpty) return;
    Provider.of<NpshProvider>(context, listen: false).updatePAtmosferica(
        newPAtmosferica: double.parse(patmosfericaController.text));

    setState(() {
      patmosfericaController.text =
          Provider.of<NpshProvider>(context, listen: false)
              .patmosferica
              .toStringAsPrecision(3);
    });
  }

  void _updateDensidad() {
    if (densidadController.text.isEmpty) return;
    Provider.of<NpshProvider>(context, listen: false)
        .updateDensidad(newDensidad: double.parse(densidadController.text));
  }

  @override
  void initState() {
    super.initState();

    marcaController = TextEditingController(
        text: Provider.of<NpshProvider>(context, listen: false).marca);
    marcaController.addListener(_updateMarca);

    serieController = TextEditingController(
        text: Provider.of<NpshProvider>(context, listen: false).serie);

    serieController.addListener(_updateSerie);

    potenciaController = TextEditingController(
        text: Provider.of<NpshProvider>(context, listen: false)
            .potencia
            .toString());

    potenciaController.addListener(_updatePotencia);

    densidadController = TextEditingController(
        text: Provider.of<NpshProvider>(context, listen: false)
            .densidad
            .toString());

    densidadController.addListener(_updateDensidad);

    patmosfericaController = TextEditingController(
        text: Provider.of<NpshProvider>(context, listen: false)
            .patmosferica
            .toString());

    patmosfericaController.addListener(_updatePAtmosferica);

    temperaturaController = TextEditingController(
        text: Provider.of<NpshProvider>(context, listen: false)
            .temperatura
            .toString());

    temperaturaController.addListener(_updateTemperatura);

    pvaporController = TextEditingController(
        text: Provider.of<NpshProvider>(context, listen: false)
            .pvapor
            .toString());
  }

  @override
  void dispose() {
    marcaController.dispose();
    serieController.dispose();
    potenciaController.dispose();
    densidadController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFromHistory =
        Provider.of<NpshProvider>(context, listen: false).fromHistory;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Estudiantes",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.start,
              ),
              const SizedBox(
                height: 18,
              ),
              Column(
                children: [
                  ...Provider.of<NpshProvider>(context)
                      .nombres
                      .asMap()
                      .entries
                      .map((entry) => Column(
                            children: [
                              Row(
                                children: [
                                  ExtendedControlledField(
                                      readOnly: isFromHistory,
                                      key: UniqueKey(),
                                      width: 840,
                                      initialValue: entry.value,
                                      label: 'Nombre',
                                      onChanged: (newNombre) =>
                                          Provider.of<NpshProvider>(context,
                                                  listen: false)
                                              .updateNombre(
                                                  index: entry.key,
                                                  nombre: newNombre)),
                                  Provider.of<NpshProvider>(context)
                                                  .nombres
                                                  .length >
                                              1 &&
                                          !isFromHistory
                                      ? IconButton(
                                          onPressed: () =>
                                              Provider.of<NpshProvider>(context,
                                                      listen: false)
                                                  .removeNombre(
                                                index: entry.key,
                                              ),
                                          icon:
                                              const Icon(Icons.delete_forever))
                                      : Container(
                                          width: 0,
                                          height: 0,
                                        ),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                            ],
                          ))
                ].toList(),
              ),
              !isFromHistory
                  ? TextButton(
                      onPressed:
                          Provider.of<NpshProvider>(context, listen: false)
                              .addNombre,
                      child: Text('Agregar estudiante'))
                  : Container(
                      width: 0,
                      height: 0,
                    ),
              const SizedBox(
                height: 12,
              ),
              Container(
                width: 940,
                height: 1,
                color: Colors.grey[200],
              ),
              const SizedBox(
                height: 24,
              ),
              const Text(
                "Datos de la bomba (opcionales)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.start,
              ),
              const SizedBox(
                height: 18,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExtendedField(
                      controller: marcaController, width: 840, label: "Marca"),
                  const SizedBox(height: 14), // <-- Set height
                  ExtendedField(
                      controller: serieController, width: 840, label: "Serie"),
                  const SizedBox(height: 14), // <-- Set height
                  ExtendedField(
                      controller: potenciaController,
                      isNumber: true,
                      label: "Potencia (HP)"),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Container(
                width: 940,
                height: 1,
                color: Colors.grey[200],
              ),
              const SizedBox(
                height: 24,
              ),
              const Text(
                "Datos del ensayo",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 18,
              ),
              ExtendedField(
                controller: densidadController,
                width: 840,
                label: "Densidad (kg/m3)",
                isNumber: true,
              ),
              const SizedBox(
                height: 14,
              ),
              ExtendedField(
                controller: patmosfericaController,
                width: 840,
                label: "Presión atmosférica (kPa)",
                isNumber: true,
              ),
              const SizedBox(
                height: 14,
              ),
              ExtendedField(
                controller: temperaturaController,
                width: 840,
                label: "Temperatura (C)",
                isNumber: true,
              ),
              const SizedBox(
                height: 14,
              ),
              ExtendedField(
                controller: pvaporController,
                width: 840,
                label: "Presión de Vapor (kPa)",
                readOnly: true,
              ),
              const SizedBox(
                height: 80,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

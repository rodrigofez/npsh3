import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:npsh3/providers/npsh.dart';
import 'package:npsh3/screens/observation_point.dart';
import 'package:npsh3/screens/plotter_npsh.dart';
import 'package:npsh3/screens/static_observation_point%20copy.dart';
import 'package:npsh3/widgets/ui/chart.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:file_picker/file_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class Plotter extends StatefulWidget {
  const Plotter({super.key});

  @override
  State<Plotter> createState() => _PlotterState();
}

class _PlotterState extends State<Plotter> {
  ScreenshotController screenshotController = ScreenshotController();

  TextEditingController _selectedQcontroller = TextEditingController();

  Future<void> _handleSave(BuildContext context) async {
    NpshProvider npshProvider =
        Provider.of<NpshProvider>(context, listen: false);

    // print(npshProvider.interpolate3(q: 62));

    if (!npshProvider.isTestComplete()) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Center(child: Text('Puntos de observación incompletos')),
          duration: const Duration(milliseconds: 1500),
          width: 280.0, // Width of the SnackBar.
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      );
      return;
    }

    npshProvider.generateNPSH3();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlotterNPSH()),
    );

    // await _pdfResults(context);
  }

  Future _pdfResults(context) async {
    var pdf = pw.Document();
    final bytes = await screenshotController.capture();

    final NpshProvider npshProvider =
        Provider.of<NpshProvider>(context, listen: false);

    final bool showTable = npshProvider.marca != "" &&
        npshProvider.serie != "" &&
        npshProvider.potencia != 0;

    const tableHeaders = ['Bomba ensayada', ''];

    final dataTable = [
      ['Marca', npshProvider.marca],
      ['Serie', npshProvider.serie],
      ['Potencia (hp)', npshProvider.potencia],
    ];

    final ByteData image = await rootBundle.load('images/ues_logo.jpg');
    Uint8List imageData = (image).buffer.asUint8List();

    final table = pw.TableHelper.fromTextArray(
      border: null,
      headers: tableHeaders,
      data: List<List<dynamic>>.generate(
        dataTable.length,
        (index) => <dynamic>[
          dataTable[index][0],
          dataTable[index][1],
        ],
      ),
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
      ),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.black,
      ),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.black,
            width: .5,
          ),
        ),
      ),
      cellAlignment: pw.Alignment.centerRight,
      cellAlignments: {0: pw.Alignment.centerLeft},
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(64),
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Column(
              children: [
                pw.Row(children: [
                  pw.SizedBox(
                      width: 60,
                      height: 60,
                      child: pw.Image(pw.MemoryImage(imageData))),
                  pw.SizedBox(width: 20),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "UNIVERSIDAD DE EL SALVADOR",
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          "FACULTAD DE INGENIERÍA Y ARQUITECTURA",
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          "ESCUELA DE INGENIERÍA MECÁNICA",
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          "DEPARTAMENTO DE SISTEMAS FLUIDOMECÁNICOS",
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ])
                ]),
                pw.SizedBox(height: 20),
                showTable ? table : pw.SizedBox(height: 0),
                //divider with line and padding
                pw.SizedBox(height: 20),
                pw.Divider(
                  thickness: 1,
                  color: PdfColors.grey200,
                ),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text(
                    "Curva NPSH3 vs Q",
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Container(
                    height: 700,
                    width: 1080,
                    child: pw.Expanded(
                      child: pw.Image(pw.MemoryImage(bytes!)),
                    ),
                  ),
                ),
                pw.SizedBox(height: 110),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Reporte: NPSH3",
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      DateTime.now().toString(),
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );
    await savePdf(pdf, context);
  }

  Future<String> savePdf(pw.Document pdf, var context) async {
    late File file;

    file = File("best_pdf.pdf");

    if (await file.exists()) {
      try {
        await file.delete();
      } on Exception catch (e) {
        print(e);
      }
    }

    String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Guarda tu archivo',
        fileName: "npsh_test",
        allowedExtensions: [
          'pdf',
        ]);

    try {
      File returnedFile = File('$outputFile.pdf');
      await returnedFile.writeAsBytes(await pdf.save());
    } catch (e) {}

    return file.path;
  }

  Widget _buildHeader({required String title, String subtitle = ""}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6, right: 6),
      child: SizedBox(
          height: 48,
          width: 100,
          child: Container(
            decoration: BoxDecoration(
                color: Color.fromARGB(10, 0, 0, 50),
                borderRadius: BorderRadius.circular(6)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (subtitle.isNotEmpty) Text(subtitle)
              ],
            ),
          )),
    );
  }

  int _observationIndex = 0;

  List<String> _selectedPoints = ['', '', '', '', ''];

  @override
  void initState() {
    super.initState();

    _selectedPoints = Provider.of<NpshProvider>(context, listen: false)
        .allObservationPoints
        .map((observationPoint) => observationPoint[0].qInicial.toString())
        .toList();

    _selectedQcontroller = TextEditingController(text: _selectedPoints[0]);
  }

  @override
  void dispose() {
    _selectedQcontroller.dispose();

    super.dispose();
  }

  void handleNextPoint() {
    _selectedQcontroller.text = _selectedPoints[_observationIndex + 1];
    setState(() {
      _observationIndex++;
    });
  }

  void handlePreviousPoint() {
    _selectedQcontroller.text = _selectedPoints[_observationIndex - 1];
    setState(() {
      _observationIndex--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final NpshProvider npshProvider = Provider.of<NpshProvider>(context);
    final NpshProvider pointsProvider =
        Provider.of<NpshProvider>(context, listen: false);

    onSelectPoint(num q) {
      npshProvider.setObservationPointQ(index: _observationIndex, newQ: q);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ensayo NPSH3'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _handleSave(context);
        },
        child: const Icon(Icons.navigate_next),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Screenshot(
                  controller: screenshotController, child: LineChartSample4()),
            ),
            const SizedBox(height: 24),
            Container(
              width: 940,
              height: 1,
              color: Colors.grey[200],
            ),
            const SizedBox(
              height: 24,
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Punto de observación ${_observationIndex + 1}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 24,
                            ),
                            DropdownMenu<String>(
                              controller: _selectedQcontroller,
                              label: Text('Selecciona un Q(gpm)'),
                              width: 150,
                              enableSearch: false,
                              enableFilter: false,
                              requestFocusOnTap: false,
                              initialSelection: '',
                              onSelected: (String? value) {
                                setState(() {
                                  _selectedPoints[_observationIndex] =
                                      value.toString();
                                });
                                onSelectPoint(double.parse(value!));
                              },
                              dropdownMenuEntries: npshProvider.allPoints
                                  .takeWhile((point) {
                                    return point.hNeta != 0.0;
                                  })
                                  .map((point) => point.qInicial)
                                  .map<DropdownMenuEntry<String>>((num value) {
                                    return DropdownMenuEntry<String>(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStatePropertyAll(
                                                    value.toString() ==
                                                            _selectedQcontroller
                                                                .text
                                                        ? Colors.blue[50]
                                                        : Colors.white)),
                                        value: value.toString(),
                                        label: value.toString());
                                  })
                                  .toList(),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _observationIndex == 0
                                    ? null
                                    : handlePreviousPoint();
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: _observationIndex == 0 ? 0 : null,
                                  backgroundColor: _observationIndex == 0
                                      ? Colors.black12
                                      : null,
                                  shadowColor: _observationIndex == 0
                                      ? Colors.transparent
                                      : null,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  )),
                              child: const Icon(Icons.navigate_before),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                _observationIndex >= 4
                                    ? null
                                    : handleNextPoint();
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: _observationIndex >= 4 ? 0 : null,
                                  backgroundColor: _observationIndex >= 4
                                      ? Colors.black12
                                      : null,
                                  shadowColor: _observationIndex >= 4
                                      ? Colors.transparent
                                      : null,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  )),
                              child: const Icon(Icons.navigate_next),
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    pointsProvider.observationPointDeltaGreaterThan3(
                            index: _observationIndex)
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check,
                                    size: 22, color: Colors.green),
                                SizedBox(width: 8),
                                Text('ΔH% es mayor o igual a 3%'),
                              ],
                            ))
                        : Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info,
                                    size: 22, color: Colors.black87),
                                SizedBox(width: 8),
                                Text('ΔH% no ha alcanzado el 3%'),
                              ],
                            )),
                    const SizedBox(
                      height: 32,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildHeader(title: "% Ap. Vs"),
                              _buildHeader(title: "Caudal"),
                              _buildHeader(title: "H teorico", subtitle: "(m)"),
                              _buildHeader(title: "PE", subtitle: "(kPa)"),
                              _buildHeader(title: "PS", subtitle: "(kPa)"),
                              _buildHeader(
                                  title: "H neta exp.", subtitle: "(m)"),
                              _buildHeader(title: "ΔH", subtitle: "%"),
                            ],
                          ),
                          SizedBox(width: 6),
                          StaticObservationPointRow(
                              point: npshProvider
                                  .allObservationPoints[_observationIndex][0]),
                          ...npshProvider
                              .allObservationPoints[_observationIndex]
                              .sublist(
                                  1,
                                  npshProvider
                                      .allObservationPoints[_observationIndex]
                                      .length)
                              .map((point) => ObservationPointRow(
                                    key: ValueKey(point.id),
                                    point: point,
                                    observationIndex: _observationIndex,
                                  ))
                              .toList(),
                          const SizedBox(
                            height: 80,
                          ),
                        ],
                      ),
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

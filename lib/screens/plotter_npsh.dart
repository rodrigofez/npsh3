import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:npsh3/providers/npsh.dart';
import 'package:npsh3/screens/observation_point.dart';
import 'package:npsh3/screens/static_observation_point%20copy.dart';
import 'package:npsh3/widgets/ui/chart.dart';
import 'package:npsh3/widgets/ui/chart_npsh.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class PlotterNPSH extends StatefulWidget {
  const PlotterNPSH({super.key});

  @override
  State<PlotterNPSH> createState() => _PlotterNPSHState();
}

class _PlotterNPSHState extends State<PlotterNPSH> {
  ScreenshotController screenshotController = ScreenshotController();

  TextEditingController _selectedQcontroller = TextEditingController();

  Future<void> _handleSave(BuildContext context) async {
    await _pdfResults(context);
  }

  Future _pdfResults(context) async {
    var pdf = pw.Document();
    final bytes = await screenshotController.capture();

    final NpshProvider npshProvider =
        Provider.of<NpshProvider>(context, listen: false);

    final bool showTable = npshProvider.marca != "" &&
        npshProvider.serie != "" &&
        npshProvider.potencia != 0;

    const tableHeaders = ['Datos', ''];

    final dataTable = [
      ['Marca', npshProvider.marca],
      ['Serie', npshProvider.serie],
      ['Potencia (hp)', npshProvider.potencia],
      ['Densidad (kg/m3)', npshProvider.densidad],
    ];

    const dataTableHeaders = [
      "% Ap. Vi",
      "Caudal",
      "PE (kPa)",
      "PS (kPa)",
      "H neta (m)"
    ];
    final dataPoints = npshProvider.allPoints
        .where((element) => element.hNeta != 0)
        .map((point) => [
              point.porcentajeApertura.toStringAsFixed(2),
              point.qInicial.toStringAsFixed(2),
              point.presionEntrada.toStringAsFixed(2),
              point.presionSalida.toStringAsFixed(2),
              point.hNeta.toStringAsFixed(2)
            ])
        .toList();

    final allObservationPoints = npshProvider.allObservationPoints
        .map(((e) => e
            .where((element) =>
                element.qInicial != 0 && element.hExperimental != 0)
            .map((e) => [
                  e.porcentajeAperturaVs.toStringAsFixed(2),
                  e.qInicial.toStringAsFixed(2),
                  e.hTeorico.toStringAsFixed(2),
                  e.presionEntrada.toStringAsFixed(2),
                  e.presionSalida.toStringAsFixed(2),
                  e.hExperimental.toStringAsFixed(2),
                  e.deltaH.toStringAsFixed(2)
                ])
            .toList()))
        .toList();

    const allDataHeaders = [
      "% Ap. Vs",
      "Caudal (gpm)",
      "H teorico (m)",
      "PE (kPa)",
      "PS (kPa)",
      "H neta exp. (m)",
      "Delta H (%)"
    ];

    final observPointsTables = allObservationPoints
        .asMap()
        .entries
        .map((entry) => pw.Column(
              children: [
                pw.SizedBox(height: 18),
                pw.Center(
                  child: pw.Text(
                    'Punto de observación ${entry.key + 1}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.TableHelper.fromTextArray(
                  border: null,
                  headers: allDataHeaders,
                  data: List<List<dynamic>>.generate(
                    entry.value.length,
                    (index) => <dynamic>[
                      entry.value[index][0],
                      entry.value[index][1],
                      entry.value[index][2],
                      entry.value[index][3],
                      entry.value[index][4],
                      entry.value[index][5],
                      entry.value[index][6],
                    ],
                  ),
                  headerStyle: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.black,
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 10),
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
                )
              ],
            ))
        .toList();

    final ByteData image = await rootBundle.load('images/ues_logo.jpg');
    Uint8List imageData = (image).buffer.asUint8List();

    final allpointstable = pw.TableHelper.fromTextArray(
      border: null,
      headers: dataTableHeaders,
      data: List<List<dynamic>>.generate(
        dataPoints.length,
        (index) => <dynamic>[
          dataPoints[index][0],
          dataPoints[index][1],
          dataPoints[index][2],
          dataPoints[index][3],
          dataPoints[index][4],
        ],
      ),
      headerStyle: pw.TextStyle(
          color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.black,
      ),
      cellStyle: const pw.TextStyle(fontSize: 10),
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
          color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.black,
      ),
      cellStyle: const pw.TextStyle(fontSize: 10),
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
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          "FACULTAD DE INGENIERÍA Y ARQUITECTURA",
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          "ESCUELA DE INGENIERÍA MECÁNICA",
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          "DEPARTAMENTO DE SISTEMAS FLUIDOMECÁNICOS",
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ])
                ]),
                pw.SizedBox(height: 16),
                showTable ? table : pw.SizedBox(height: 0),
                //divider with line and padding
                pw.SizedBox(height: 16),
                pw.Divider(
                  thickness: 1,
                  color: PdfColors.grey200,
                ),
                pw.SizedBox(height: 16),
                pw.Center(
                  child: pw.Text(
                    "Curva NPSH3 vs Q",
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Center(
                  child: pw.Container(
                    height: 700,
                    width: 1080,
                    child: pw.Expanded(
                      child: pw.Image(pw.MemoryImage(bytes!)),
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    "Puntos de observación",
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                allpointstable,
                pw.SizedBox(height: 20),
                ...observPointsTables
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
        child: const Icon(Icons.save),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              'Resultados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Screenshot(
                  controller: screenshotController,
                  child: Column(
                    children: [
                      LineChartSample4(),
                      ChartNPSH(),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

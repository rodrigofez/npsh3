import 'dart:io';
import 'package:flutter/material.dart';
import 'package:npsh3/providers/npsh.dart';
import 'package:npsh3/screens/observation_point.dart';
import 'package:npsh3/screens/static_observation_point%20copy.dart';
import 'package:npsh3/widgets/cavitacion/cavitacion_chart.dart';
import 'package:file_picker/file_picker.dart';
import 'package:npsh3/widgets/ui/conditional_parent_widget.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class Cavitacion extends StatefulWidget {
  const Cavitacion({super.key});

  @override
  State<Cavitacion> createState() => _CavitacionState();
}

class _CavitacionState extends State<Cavitacion> {
  ScreenshotController screenshotController = ScreenshotController();

  TextEditingController _selectedQcontroller = TextEditingController();

  Widget _buildHeader({required String title, String subtitle = ""}) {
    return Expanded(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
            color: Colors.transparent, borderRadius: BorderRadius.circular(4)),
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
      ),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        var parentWidth = constraints.maxWidth - 40;
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(
                'Punto de observación ${_observationIndex + 1}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: parentWidth,
                child: const CavitacionChart(),
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
                                label: const Text('Seleccione un Q(gpm)'),
                                width: 200,
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
                                    .map<DropdownMenuEntry<String>>(
                                        (num value) {
                                      return DropdownMenuEntry<String>(
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStatePropertyAll(value
                                                              .toString() ==
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
                                    elevation:
                                        _observationIndex == 0 ? 0 : null,
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
                                    elevation:
                                        _observationIndex >= 4 ? 0 : null,
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
                      ConditionalParentWidget(
                        condition: parentWidth <= 800,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _buildHeader(title: "% Ap. Vs"),
                                _buildHeader(title: "Caudal"),
                                _buildHeader(
                                    title: "H teorico", subtitle: "(m)"),
                                _buildHeader(title: "PE", subtitle: "(kPa)"),
                                _buildHeader(title: "PS", subtitle: "(kPa)"),
                                _buildHeader(
                                    title: "H neta exp.", subtitle: "(m)"),
                                _buildHeader(title: "ΔH", subtitle: "%"),
                              ],
                            ),
                            const SizedBox(height: 14),
                            StaticObservationPointRow(
                                point: npshProvider
                                        .allObservationPoints[_observationIndex]
                                    [0]),
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
                        conditionalBuilder: (Widget child) =>
                            SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(width: 800, child: child)),
                      ),
                      // SingleChildScrollView(
                      //   scrollDirection: Axis.horizontal,
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Row(
                      //         children: [
                      //           _buildHeader(title: "% Ap. Vs"),
                      //           _buildHeader(title: "Caudal"),
                      //           _buildHeader(
                      //               title: "H teorico", subtitle: "(m)"),
                      //           _buildHeader(title: "PE", subtitle: "(kPa)"),
                      //           _buildHeader(title: "PS", subtitle: "(kPa)"),
                      //           _buildHeader(
                      //               title: "H neta exp.", subtitle: "(m)"),
                      //           _buildHeader(title: "ΔH", subtitle: "%"),
                      //         ],
                      //       ),
                      //       const SizedBox(width: 6),
                      //       StaticObservationPointRow(
                      //           point: npshProvider
                      //                   .allObservationPoints[_observationIndex]
                      //               [0]),
                      //       ...npshProvider
                      //           .allObservationPoints[_observationIndex]
                      //           .sublist(
                      //               1,
                      //               npshProvider
                      //                   .allObservationPoints[_observationIndex]
                      //                   .length)
                      //           .map((point) => ObservationPointRow(
                      //                 key: ValueKey(point.id),
                      //                 point: point,
                      //                 observationIndex: _observationIndex,
                      //               ))
                      //           .toList(),
                      //       const SizedBox(
                      //         height: 80,
                      //       ),
                      //     ],
                      //   ),
                      // )
                    ],
                  )),
            ],
          ),
        );
      },
    );
  }
}

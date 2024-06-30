import 'package:flutter/material.dart';
import 'package:npsh3/providers/npsh.dart';
import 'package:npsh3/widgets/ui/conditional_parent_widget.dart';
import 'package:npsh3/widgets/curva_caracteristica/curva_caracteristica_chart.dart';
import 'package:npsh3/widgets/curva_caracteristica/plotter.dart';
import 'package:npsh3/screens/point.dart';
import 'package:provider/provider.dart';

class CurvaCaracteristica extends StatefulWidget {
  const CurvaCaracteristica({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CurvaCaracteristicaState();
  }
}

class _CurvaCaracteristicaState extends State<CurvaCaracteristica> {
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _plot(BuildContext context) {
    bool isReady = Provider.of<NpshProvider>(context, listen: false).isReady;

    if (!isReady) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Debes llenar todos los campos antes de continuar'),
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Plotter()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final NpshProvider npshProvider = Provider.of<NpshProvider>(context);

    return LayoutBuilder(builder: (context, constraints) {
      var parentWidth = constraints.maxWidth - 40;
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Builder(builder: (context) {
          return Container(
            margin: const EdgeInsets.all(20),
            width: parentWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    width: parentWidth,
                    child: const CurvaCaracteristicaChart()),
                const SizedBox(height: 24),
                Container(
                  width: 940,
                  height: 1,
                  color: Colors.grey[200],
                ),
                const SizedBox(
                  height: 24,
                ),
                ConditionalParentWidget(
                  condition: parentWidth <= 500,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildHeader(title: "% Ap. Vi."),
                          _buildHeader(title: "Caudal"),
                          _buildHeader(title: "PE", subtitle: "(kPa)"),
                          _buildHeader(title: "PS", subtitle: "(kPa)"),
                          _buildHeader(title: "H neta", subtitle: "(m)"),
                        ],
                      ),
                      const SizedBox(width: 6),
                      ...npshProvider.allPoints
                          .map((point) => PointRow(
                                point: point,
                              ))
                          .toList(),
                      const SizedBox(
                        height: 80,
                      ),
                    ],
                  ),
                  conditionalBuilder: (Widget child) => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(width: 500, child: child)),
                ),
              ],
            ),
          );
        }),
      );
    });
  }
}

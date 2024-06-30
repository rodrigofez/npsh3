import 'package:flutter/material.dart';
import 'package:npsh3/widgets/cavitacion/cavitacion_chart.dart';
import 'package:npsh3/widgets/ui/chart_npsh.dart';
import 'package:screenshot/screenshot.dart';

class NPSH3Screen extends StatefulWidget {
  final ScreenshotController screenshotController;
  const NPSH3Screen({super.key, required this.screenshotController});

  @override
  State<NPSH3Screen> createState() => _NPSH3ScreenState();
}

class _NPSH3ScreenState extends State<NPSH3Screen> {
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
    return LayoutBuilder(builder: (context, constraints) {
      var parentWidth = constraints.maxWidth;
      return SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // const Text(
            //   'Resultados',
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
            SizedBox(
              width: parentWidth,
              // margin: const EdgeInsets.only(top: 20),
              child: Screenshot(
                  controller: widget.screenshotController,
                  child: Column(
                    children: [
                      const CavitacionChart(),
                      ChartNPSH(),
                    ],
                  )),
            ),
            const SizedBox(height: 100),
          ],
        ),
      );
    });
  }
}

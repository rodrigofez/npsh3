import 'package:flutter/material.dart';
import 'package:npsh3/providers/npsh.dart';
import 'package:npsh3/services/generate_pdf.dart';
import 'package:npsh3/widgets/cavitacion/main.dart';
import 'package:npsh3/widgets/curva_caracteristica/main.dart';
import 'package:npsh3/widgets/initial_setup/main.dart';
import 'package:npsh3/widgets/npsh3/main.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

const List<String> floatingActionLabel = <String>[
  "Comenzar Ensayo",
  "Continuar",
  "Continuar",
  "Exportar reporte"
];

const List<String> appBarLabel = <String>[
  "Datos básicos",
  "Curva característica",
  "Ensayo NPSH3",
  "Resultados"
];

class EnsayoScreen extends StatefulWidget {
  const EnsayoScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _EnsayoScreenState();
  }
}

class _EnsayoScreenState extends State<EnsayoScreen> {
  ScreenshotController screenshotController = ScreenshotController();
  int currentPageIndex = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _verificarDatosIniciales(BuildContext context) {
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
    }

    return isReady;
  }

  bool _verificarPuntosDeObservacion(BuildContext context) {
    NpshProvider npshProvider =
        Provider.of<NpshProvider>(context, listen: false);

    final isComplete = npshProvider.isTestComplete();

    if (!isComplete) {
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
    }
    return isComplete;
  }

  @override
  Widget build(BuildContext context) {
    onNextPage() {
      NpshProvider npshProvider =
          Provider.of<NpshProvider>(context, listen: false);
      if (currentPageIndex == 2 && !_verificarPuntosDeObservacion(context)) {
        return;
      }

      if (currentPageIndex == 2) {
        npshProvider.generateNPSH3();
      }

      if (currentPageIndex == 3) {
        Utils.handleSave(context, screenshotController);
        return;
      }

      setState(() {
        currentPageIndex++;
      });
    }

    onPrevPage() {
      if (currentPageIndex == 0) {
        return;
      }

      setState(() {
        currentPageIndex--;
      });
    }

    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 251, 251, 251),
        appBar: AppBar(
          title: Text(appBarLabel[currentPageIndex]),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          toolbarHeight: 70,
          shadowColor: Colors.black12,
          surfaceTintColor: Colors.transparent,
          leading: currentPageIndex != 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Regresar',
                  onPressed: () {
                    onPrevPage();
                  },
                )
              : null,
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: Row(
            children: [
              const Icon(Icons.play_arrow_rounded),
              const SizedBox(width: 10),
              Text(floatingActionLabel[currentPageIndex]),
            ],
          ),
          onPressed: () {
            onNextPage();
          },
          // child: const Icon(Icons.play_arrow_rounded),
        ),
        body: <Widget>[
          const InitialSetup(),
          const CurvaCaracteristica(),
          const Cavitacion(),
          NPSH3Screen(screenshotController: screenshotController),
        ][currentPageIndex]);
  }
}

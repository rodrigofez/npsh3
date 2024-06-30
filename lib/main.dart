import 'package:flutter/material.dart';
import 'package:npsh3/screens/ensayo.dart';
import 'package:npsh3/providers/npsh.dart';
import 'package:npsh3/screens/historial.dart';
import 'package:provider/provider.dart';

class ExampleDestination {
  const ExampleDestination(this.label, this.icon, this.selectedIcon);

  final String label;
  final Widget icon;
  final Widget selectedIcon;
}

const List<ExampleDestination> destinations = <ExampleDestination>[
  ExampleDestination('Ensayo', Icon(Icons.monitor_heart_sharp),
      Icon(Icons.monitor_heart_sharp)),
  ExampleDestination(
      'Historial', Icon(Icons.folder_copy_outlined), Icon(Icons.folder_copy)),
];

void main() {
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => NpshProvider())],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: colorScheme),
      title: 'NPSH3',
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Key _refreshKey = UniqueKey();
  int screenIndex = 0;
  late bool showNavigationDrawer;

  void handleScreenChanged(int selectedScreen) {
    setState(() {
      screenIndex = selectedScreen;
    });
  }

  Future<void> handleSaveEnsayo(BuildContext context) async {
    final NpshProvider npshProvider =
        Provider.of<NpshProvider>(context, listen: false);
    await npshProvider.guardarEnsayo();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Center(child: Text('Ensayo guardado')),
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

  handleNewEnsayo(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("Confirmar"),
      onPressed: () {
        onNewEnsayo(context);
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Nuevo Ensayo"),
      content: const Text("¿Está seguro que quiere crear un nuevo ensayo?"),
      actions: [
        okButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> onNewEnsayo(BuildContext context) async {
    final NpshProvider npshProvider =
        Provider.of<NpshProvider>(context, listen: false);
    npshProvider.nuevoEnsayo();
    setState(() {
      _refreshKey = UniqueKey();
    });
    setState(() {
      screenIndex = 0;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Nuevo ensayo creado'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          bottom: false,
          top: false,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: NavigationRail(
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FloatingActionButton(
                      heroTag: 'guardar',
                      tooltip: "Nuevo",
                      elevation: 0,
                      onPressed: () {
                        handleNewEnsayo(context);
                      },
                      child: const Icon(Icons.add),
                    ),
                  ),
                  minWidth: 50,
                  destinations: destinations.map(
                    (ExampleDestination destination) {
                      return NavigationRailDestination(
                        label: Text(destination.label),
                        icon: destination.icon,
                        selectedIcon: destination.selectedIcon,
                      );
                    },
                  ).toList(),
                  trailing: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FloatingActionButton(
                      heroTag: 'action',
                      elevation: 0,
                      onPressed: () {
                        handleSaveEnsayo(context);
                      },
                      // mini: true,
                      tooltip: "Guardar",
                      child: const Icon(Icons.save),
                    ),
                  ),
                  // ExampleDestination('Guardar', Icon(Icons.save_outlined), Icon(Icons.save)),

                  selectedIndex: screenIndex,
                  useIndicator: true,
                  onDestinationSelected: (int index) {
                    setState(() {
                      screenIndex = index;
                    });
                  },
                ),
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: <Widget>[
                  EnsayoScreen(
                    key: _refreshKey,
                  ),
                  const HistorialScreen()
                ][screenIndex],
              ),
            ],
          )),
    );
  }
}

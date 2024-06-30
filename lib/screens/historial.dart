import 'package:flutter/material.dart';
import 'package:npsh3/models/ensayo.dart';
import 'package:npsh3/providers/npsh.dart';
import 'package:provider/provider.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 251, 251, 251),
        appBar: AppBar(
          title: const Text(
            'Ensayos Guardados',
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          toolbarHeight: 70,
          shadowColor: Colors.black12,
          surfaceTintColor: Colors.transparent,
        ),
        body: const DataTableExample());
  }
}

class DataTableExample extends StatefulWidget {
  const DataTableExample({super.key});

  @override
  State<DataTableExample> createState() => _DataTableExampleState();
}

class _DataTableExampleState extends State<DataTableExample> {
  @override
  Widget build(BuildContext context) {
    final NpshProvider npshProvider = Provider.of<NpshProvider>(context);

    confirmarCargarEnsayo(BuildContext context, Ensayo ensayo) {
      // set up the button
      Widget okButton = TextButton(
        child: const Text("Confirmar"),
        onPressed: () {
          npshProvider.cargarEnsayo(ensayo);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Center(child: Text('Ensayo cargado')),
              duration: const Duration(milliseconds: 1500),
              width: 280.0, // Width of the SnackBar.
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          );
        },
      );
      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: const Text("Cargar Ensayo"),
        content: const Text("¿Está seguro que quiere cargar este ensayo?"),
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

    return FutureBuilder(
        future: npshProvider.getEnsayosGuardados(),
        builder: (context, snapshot) {
          final ensayos = snapshot.data ?? [];
          return LayoutBuilder(builder: (context, constraints) {
            final parentWidth = constraints.maxWidth;
            return SingleChildScrollView(
              child: SizedBox(
                width: parentWidth,
                child: DataTable(
                  showCheckboxColumn: false,
                  onSelectAll: (value) {},
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text('Bomba'),
                    ),
                    DataColumn(
                      label: Text('Fecha'),
                    ),
                  ],
                  rows: List<DataRow>.generate(
                    ensayos.length,
                    (int index) => DataRow(
                      color: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                        // All rows will have the same selected color.
                        if (states.contains(WidgetState.selected)) {
                          return Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.08);
                        }
                        // Even rows will have a grey color.
                        if (index.isEven) {
                          return Colors.grey.withOpacity(0.05);
                        }
                        return null; // Use default value for other states and odd rows.
                      }),
                      cells: <DataCell>[
                        DataCell(Text(
                            '${ensayos[index].data.marca} ${ensayos[index].data.serie} ${ensayos[index].data.potencia} HP')),
                        DataCell(Text(DateTime.parse(ensayos[index].savedAt)
                            .toLocal()
                            .toString()))
                      ],
                      // selected: selected[index],
                      onSelectChanged: (bool? value) {
                        confirmarCargarEnsayo(context, ensayos[index].data);
                      },
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }
}

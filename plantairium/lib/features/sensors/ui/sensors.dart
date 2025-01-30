import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:plantairium/common/utils/colors.dart';
import 'package:plantairium/features/sensors/controller/sensor_controller.dart';

class SensorsView extends ConsumerWidget {
  const SensorsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorsAsyncValue = ref.watch(sensorsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione Sensori'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_box_rounded,
              color: Palette.primary,
            ),
            tooltip: 'Aggiungi Sensore',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return const AddSensorDialog();
                },
              );
            },
          ),
        ],
      ),
      body: sensorsAsyncValue.when(
        data: (sensors) {
          if (sensors.isEmpty) {
            return const Center(
              child: Text('Nessun sensore disponibile.'),
            );
          }
          return Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height /
                    3, // 1/3 della schermata
                child: Lottie.asset(
                    'assets/lottie/Seeding-bro.json'), // Sostituisci con il percorso del tuo file Lottie
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: sensors.length,
                  itemBuilder: (context, index) {
                    final sensor = sensors[index];
                    return Dismissible(
                      key: Key(sensor['Id'].toString()),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        ref
                            .read(sensorsControllerProvider.notifier)
                            .deleteSensor(sensor['Id'])
                            .then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sensore eliminato')),
                          );
                        });
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: Image.asset('assets/img/sensor.png',
                              fit: BoxFit.cover),
                          title: Text(sensor['Nome'] as String? ?? ''),
                          subtitle: Text('ID Utente: ${sensor['IdUtente']}'),
                          trailing: IconButton(
                            icon: Icon(Icons.edit, color: Palette.primary),
                            tooltip: 'Modifica Sensore',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return EditSensorDialog(sensor: sensor);
                                },
                              );
                            },
                          ),
                          onTap: () {
                            final int sensorId = sensor['Id'];
                            context.goNamed(
                              'plants',
                              pathParameters: {
                                'id': sensorId.toString()
                              }, // ✅ Passiamo solo l'ID qui
                              extra: sensor[
                                  'Features'], // ✅ Passiamo le "Features" come extra
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Errore: $error'),
        ),
      ),
    );
  }
}

class AddSensorDialog extends ConsumerStatefulWidget {
  const AddSensorDialog({Key? key}) : super(key: key);

  @override
  _AddSensorDialogState createState() => _AddSensorDialogState();
}

class _AddSensorDialogState extends ConsumerState<AddSensorDialog> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController tipoController = TextEditingController();
  final TextEditingController dataInstallazioneController =
      TextEditingController();
  DateTime? selectedDate;

  @override
  void dispose() {
    nomeController.dispose();
    tipoController.dispose();
    dataInstallazioneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dataInstallazioneController.text =
            DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Aggiungi Sensore',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(nomeController, 'Nome Sensore', Icons.sensors),
            _buildDateField(context),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Palette.primary),
              onPressed: () {
                final nome = nomeController.text.trim();
                final features = {
                  "tipo": tipoController.text.trim(),
                  "dataInstallazione": dataInstallazioneController.text.trim(),
                };

                ref
                    .read(sensorsControllerProvider.notifier)
                    .addSensor(nome, features)
                    .then((_) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Sensore aggiunto con successo')),
                  );
                });
              },
              child:
                  const Text('Aggiungi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: dataInstallazioneController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Data di Installazione',
          prefixIcon: Icon(Icons.calendar_today, color: Palette.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        onTap: () => _selectDate(context),
      ),
    );
  }
}

/// **Dialog per Modificare un Sensore**
class EditSensorDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> sensor;

  const EditSensorDialog({Key? key, required this.sensor}) : super(key: key);

  @override
  _EditSensorDialogState createState() => _EditSensorDialogState();
}

class _EditSensorDialogState extends ConsumerState<EditSensorDialog> {
  late TextEditingController nomeController;
  late TextEditingController tipoController;
  late TextEditingController dataInstallazioneController;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.sensor['Nome']);
    tipoController = TextEditingController(text: widget.sensor['Tipo'] ?? '');
    dataInstallazioneController =
        TextEditingController(text: widget.sensor['DataInstallazione'] ?? '');

    if (dataInstallazioneController.text.isNotEmpty) {
      try {
        selectedDate =
            DateFormat('dd/MM/yyyy').parse(dataInstallazioneController.text);
      } catch (e) {
        selectedDate = null;
      }
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    tipoController.dispose();
    dataInstallazioneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dataInstallazioneController.text =
            DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifica Sensore',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(nomeController, 'Nome Sensore', Icons.sensors),
            _buildDateField(context),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Palette.primary),
              onPressed: () {
                final nome = nomeController.text.trim();
                final features = {
                  "tipo": tipoController.text.trim(),
                  "dataInstallazione": dataInstallazioneController.text.trim(),
                };

                ref
                    .read(sensorsControllerProvider.notifier)
                    .updateSensor(widget.sensor['Id'], nome, features)
                    .then((_) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Sensore aggiornato con successo')),
                  );
                });
              },
              child:
                  const Text('Modifica', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: dataInstallazioneController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Data di Installazione',
          prefixIcon: Icon(Icons.calendar_today, color: Palette.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        onTap: () => _selectDate(context),
      ),
    );
  }
}

Widget _buildTextField(
    TextEditingController controller, String label, IconData icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Palette.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    ),
  );
}

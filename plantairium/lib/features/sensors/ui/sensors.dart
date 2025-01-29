import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plantairium/common/navigation/router/routes.dart';
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
            icon: const Icon(Icons.add),
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
          return ListView.builder(
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
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        context.goNamed(AppRoute.sensor.name);
                      },
                    ),
                  ),
                );
              },
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




class AddSensorDialog extends ConsumerWidget {
  const AddSensorDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nomeController = TextEditingController();
    final tipoController = TextEditingController();
    final intervalloController = TextEditingController();

    return AlertDialog(
      title: const Text('Aggiungi Sensore'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nomeController,
            decoration: const InputDecoration(labelText: 'Nome Sensore'),
          ),
          TextField(
            controller: tipoController,
            decoration: const InputDecoration(labelText: 'Tipo Sensore'),
          ),
          TextField(
            controller: intervalloController,
            decoration: const InputDecoration(labelText: 'Intervallo Lettura'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        TextButton(
          onPressed: () {
            final nome = nomeController.text;
            final features = {
              "tipo": tipoController.text,
              "intervallo": intervalloController.text,
            };

            ref
                .read(sensorsControllerProvider.notifier)
                .addSensor(nome, features)
                .then((_) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sensore aggiunto')),
              );
            });
          },
          child: const Text('Aggiungi'),
        ),
      ],
    );
  }
}



class EditSensorDialog extends ConsumerWidget {
  final Map<String, dynamic> sensor;
  const EditSensorDialog({Key? key, required this.sensor}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nomeController = TextEditingController(text: sensor['Nome']);
    final tipoController = TextEditingController(
        text: sensor['Features']?['tipo'] ?? '');
    final intervalloController = TextEditingController(
        text: sensor['Features']?['intervallo'] ?? '');

    return AlertDialog(
      title: const Text('Modifica Sensore'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nomeController,
            decoration: const InputDecoration(labelText: 'Nome Sensore'),
          ),
          TextField(
            controller: tipoController,
            decoration: const InputDecoration(labelText: 'Tipo Sensore'),
          ),
          TextField(
            controller: intervalloController,
            decoration: const InputDecoration(labelText: 'Intervallo Lettura'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        TextButton(
          onPressed: () {
            final nome = nomeController.text;
            final features = {
              "tipo": tipoController.text,
              "intervallo": intervalloController.text,
            };

            ref
                .read(sensorsControllerProvider.notifier)
                .updateSensor(sensor['Id'], nome, features)
                .then((_) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sensore aggiornato')),
              );
            });
          },
          child: const Text('Modifica'),
        ),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plantairium/common/navigation/router/routes.dart';
import '../controller/plants_controller.dart';

class PlantsView extends ConsumerWidget {
  final int idSensore;

  const PlantsView({Key? key, required this.idSensore}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Chiamare il metodo fetchPlants quando il widget viene costruito
    ref.read(plantsControllerProvider.notifier).fetchPlants(idSensore);

    // Osserva lo stato del provider
    final plantsAsyncValue = ref.watch(plantsControllerProvider);

    return Scaffold(
        appBar: AppBar(
        title: const Text('Gestione Piante'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.goNamed(AppRoute.sensors.name);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Aggiungi Pianta',
            
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return  AddPlantDialog(idSensore: idSensore);
                },
              );
            },
          ),
        ],
      ),
      body: plantsAsyncValue.when(
        data: (plants) {
          if (plants.isEmpty) {
            return const Center(
              child: Text('Nessuna pianta trovata'),
            );
          }
          return ListView.builder(
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              return Card(
                child: ListTile(
                  title: Text(plant['Nome']),
                  subtitle: Text(plant['Specie'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Modifica pianta
                    },
                  ),
                  onTap: () {
                    // Dettagli o altre azioni
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Errore: ${error.toString()}'),
        ),
      ),
    );
  }
}

class AddPlantDialog extends StatefulWidget {
  final int idSensore;

  const AddPlantDialog({Key? key, required this.idSensore}) : super(key: key);

  @override
  State<AddPlantDialog> createState() => _AddPlantDialogState();
}

class _AddPlantDialogState extends State<AddPlantDialog> {
  late TextEditingController nameController;
  late TextEditingController specieController;
  late TextEditingController descriptionController;
  late TextEditingController dateController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    specieController = TextEditingController();
    descriptionController = TextEditingController();
    dateController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    specieController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return AlertDialog(
          title: const Text('Aggiungi Pianta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: specieController,
                decoration: const InputDecoration(labelText: 'Specie'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descrizione'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Data Piantumazione'),
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
                ref.read(plantsControllerProvider.notifier).addPlant(
                      idSensore: widget.idSensore,
                      nome: nameController.text,
                      specie: specieController.text,
                      descrizione: descriptionController.text,
                      dataPiantumazione: dateController.text,
                    );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pianta aggiunta con successo')),
                );
              },
              child: const Text('Aggiungi'),
            ),
          ],
        );
      },
    );
  }
}

class EditPlantDialog extends StatefulWidget {
  final Map<String, dynamic> plant;

  const EditPlantDialog({Key? key, required this.plant}) : super(key: key);

  @override
  State<EditPlantDialog> createState() => _EditPlantDialogState();
}

class _EditPlantDialogState extends State<EditPlantDialog> {
  late TextEditingController nameController;
  late TextEditingController specieController;
  late TextEditingController descriptionController;
  late TextEditingController dateController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.plant['Nome']);
    specieController = TextEditingController(text: widget.plant['Specie']);
    descriptionController =
        TextEditingController(text: widget.plant['Descrizione']);
    dateController =
        TextEditingController(text: widget.plant['DataPiantumazione']);
  }

  @override
  void dispose() {
    nameController.dispose();
    specieController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return AlertDialog(
          title: const Text('Modifica Pianta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: specieController,
                decoration: const InputDecoration(labelText: 'Specie'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descrizione'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Data Piantumazione'),
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
                ref.read(plantsControllerProvider.notifier).updatePlant(
                      id: widget.plant['Id'],
                      idSensore: widget.plant['IdSensore'],
                      nome: nameController.text,
                      specie: specieController.text,
                      descrizione: descriptionController.text,
                      dataPiantumazione: dateController.text,
                    );
                Navigator.of(context).pop();
              },
              child: const Text('Salva'),
            ),
          ],
        );
      },
    );
  }
}
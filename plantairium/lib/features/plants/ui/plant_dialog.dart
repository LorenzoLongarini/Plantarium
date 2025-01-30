import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controller/plants_controller.dart';
import 'package:plantairium/common/utils/colors.dart';

class AddPlantDialog extends ConsumerStatefulWidget {
  final int idSensore;

  const AddPlantDialog({Key? key, required this.idSensore}) : super(key: key);

  @override
  _AddPlantDialogState createState() => _AddPlantDialogState();
}

class _AddPlantDialogState extends ConsumerState<AddPlantDialog> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController specieController = TextEditingController();
  final TextEditingController descrizioneController = TextEditingController();
  final TextEditingController dataPiantumazioneController =
      TextEditingController();
  DateTime? selectedDate;

  @override
  void dispose() {
    nomeController.dispose();
    specieController.dispose();
    descrizioneController.dispose();
    dataPiantumazioneController.dispose();
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
        dataPiantumazioneController.text =
            DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Aggiungi Pianta',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(nomeController, 'Nome Pianta', Icons.eco),
            _buildTextField(specieController, 'Specie', Icons.grass),
            _buildTextField(
                descrizioneController, 'Descrizione', Icons.description),
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
                final specie = specieController.text.trim();
                final descrizione = descrizioneController.text.trim();
                final dataPiantumazione =
                    dataPiantumazioneController.text.trim();

                if (nome.isNotEmpty &&
                    specie.isNotEmpty &&
                    dataPiantumazione.isNotEmpty) {
                  ref
                      .read(plantsControllerProvider(widget.idSensore).notifier)
                      .addPlant(
                        idSensore: widget.idSensore,
                        nome: nome,
                        specie: specie,
                        descrizione: descrizione.isEmpty ? null : descrizione,
                        dataPiantumazione: dataPiantumazione,
                      )
                      .then((_) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Pianta aggiunta con successo')),
                    );
                  });
                }
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
        controller: dataPiantumazioneController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Data Piantumazione',
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
}

class EditPlantDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> plant;
  final int idSensore;

  const EditPlantDialog(
      {Key? key, required this.plant, required this.idSensore})
      : super(key: key);

  @override
  _EditPlantDialogState createState() => _EditPlantDialogState();
}

class _EditPlantDialogState extends ConsumerState<EditPlantDialog> {
  late TextEditingController nomeController;
  late TextEditingController specieController;
  late TextEditingController descrizioneController;
  late TextEditingController dataPiantumazioneController;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.plant['Nome']);
    specieController = TextEditingController(text: widget.plant['Specie']);
    descrizioneController =
        TextEditingController(text: widget.plant['Descrizione'] ?? '');
    dataPiantumazioneController =
        TextEditingController(text: widget.plant['DataPiantumazione'] ?? '');
  }

  @override
  void dispose() {
    nomeController.dispose();
    specieController.dispose();
    descrizioneController.dispose();
    dataPiantumazioneController.dispose();
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
        dataPiantumazioneController.text =
            DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifica Pianta',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(nomeController, 'Nome Pianta', Icons.eco),
            _buildTextField(specieController, 'Specie', Icons.grass),
            _buildTextField(descrizioneController, 'Descrizione (opzionale)',
                Icons.description),
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
                final specie = specieController.text.trim();
                final descrizione = descrizioneController.text.trim();
                final dataPiantumazione =
                    dataPiantumazioneController.text.trim();

                if (nome.isNotEmpty &&
                    specie.isNotEmpty &&
                    dataPiantumazione.isNotEmpty) {
                  ref
                      .read(plantsControllerProvider(widget.idSensore).notifier)
                      .updatePlant(
                        id: widget.plant['Id'],
                        idSensore: widget.idSensore,
                        nome: nome,
                        specie: specie,
                        descrizione: descrizione.isEmpty ? null : descrizione,
                        dataPiantumazione: dataPiantumazione,
                      )
                      .then((_) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Pianta modificata con successo')),
                    );
                  });
                }
              },
              child: const Text('Salva Modifiche',
                  style: TextStyle(color: Colors.white)),
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
        controller: dataPiantumazioneController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Data di Piantumazione',
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
}

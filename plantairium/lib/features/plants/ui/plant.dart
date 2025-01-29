import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:open_filex/open_filex.dart';
import 'package:plantairium/features/report/controller/report_controller.dart';
import '../controller/plants_controller.dart';
import 'dart:math';

class PlantsView extends ConsumerStatefulWidget {
  final int idSensore;
  final Map<String, dynamic> sensorFeatures;

  const PlantsView({Key? key, required this.idSensore, required this.sensorFeatures})
      : super(key: key);

  @override
  _PlantsViewState createState() => _PlantsViewState();
}

class _PlantsViewState extends ConsumerState<PlantsView> {
  bool showFeatures = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(plantsControllerProvider(widget.idSensore).notifier).fetchPlants();
    });
  }

  @override
  Widget build(BuildContext context) {
    print("📢 [DEBUG] PlantsView aperta con IdSensore: ${widget.idSensore}");
    final plantsAsyncValue = ref.watch(plantsControllerProvider(widget.idSensore));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione Piante'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.goNamed('home');
          },
        ),
      ),
      body: Column(
        children: [
          _buildSensorCard(),
          Expanded(
            child: plantsAsyncValue.when(
              data: (plants) {
                if (plants.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aggiungi una pianta!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: plants.length,
                  itemBuilder: (context, index) {
                    final plant = plants[index];
                    return _buildPlantCard(plant);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Errore: ${error.toString()}')),
            ),
          ),
        ],
      ),
    );
  }
  /// **🔹 Card della Pianta**
  Widget _buildPlantCard(Map<String, dynamic> plant) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(plant['Nome']),
        subtitle: Text(plant['Specie'] ?? ''),
        trailing: _buildReportButtons(plant),
      ),
    );
  }

Widget _buildReportButtons(Map<String, dynamic> plant) {
  final reportController = ref.read(reportControllerProvider.notifier);
  final pdfPath = ref.watch(reportControllerProvider);

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
        tooltip: 'Genera Report',
        onPressed: () async {
          print("📢 [DEBUG] Generazione report per pianta: ${plant['Nome']}");

          // ✅ Verifica che le feature non siano null
          if (widget.sensorFeatures["features"] == null ||
              widget.sensorFeatures["features"].isEmpty) {
            print("❌ [DEBUG] Errore: le features del sensore sono null o vuote");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('❌ Errore: Nessuna feature disponibile per il report!')),
            );
            return;
          }

          // 1️⃣ Processiamo i dati per calcolare media, max, min, stdDev
          Map<String, dynamic> processedData = processSensorData(widget.sensorFeatures["features"]);

          // 2️⃣ Generiamo il prompt ottimizzato
          String prompt = generatePrompt(plant['Nome'], plant['Specie'] ?? 'Specie sconosciuta', processedData);

          try {
            // 3️⃣ Inviamo la richiesta con i dati ottimizzati
            await reportController.generateAndSaveReport(
              plant['Nome'],
              plant['Specie'] ?? 'Specie sconosciuta',
              processedData,
              prompt,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Report generato con successo!')),
            );
          } catch (e) {
            print("❌ [DEBUG] Errore durante la generazione del PDF: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('❌ Errore durante la generazione del report!')),
            );
          }
        },
      ),
      if (pdfPath != null)
        IconButton(
          icon: const Icon(Icons.open_in_new, color: Colors.green),
          tooltip: 'Apri Report',
          onPressed: () {
            OpenFilex.open(pdfPath);
          },
        ),
    ],
  );
}


  /// **🔹 Card delle Feature del Sensore**
  Widget _buildSensorCard() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ID Sensore: ${widget.idSensore}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Nome Sensore: Sensore Test"),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showFeatures = !showFeatures;
                });
              },
              child: Text(showFeatures ? "Nascondi Features" : "Mostra Features"),
            ),
            if (showFeatures) _buildFeatureCharts(), // ✅ Mostriamo i grafici solo se necessario
          ],
        ),
      ),
    );
  }

  /// **🔹 Grafici delle Feature del Sensore**
  Widget _buildFeatureCharts() {
    final Map<String, List<dynamic>> allFeatures = {};

    if (widget.sensorFeatures.containsKey("features") &&
        widget.sensorFeatures["features"] is Map<String, dynamic>) {
      final Map<String, dynamic> features = widget.sensorFeatures["features"];

      features.forEach((key, value) {
        if (key.toLowerCase() != "id" && key.toLowerCase() != "dateandtime") {
          if (value is List) {
            allFeatures[key] = value;
          }
        }
      });
    }

    if (allFeatures.isEmpty) {
      return const Center(
        child: Text("Nessuna feature disponibile."),
      );
    }

    return SizedBox(
      height: 400,
      child: ListView(
        children: allFeatures.entries.map((entry) {
          // Trova il valore minimo della serie
          double minValue = double.infinity;
          for (var val in entry.value) {
            if (val is num && val.toDouble() < minValue) {
              minValue = val.toDouble();
            }
          }

          return SizedBox(
            height: 250,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: 23,
                        titlesData: FlTitlesData(
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                if (value == 0) return const Text("0:00", style: TextStyle(fontSize: 14));
                                if (value == 12) return const Text("12:00", style: TextStyle(fontSize: 14));
                                if (value == 23) return const Text("23:00", style: TextStyle(fontSize: 14));
                                return const Text("");
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                // Nasconde il valore minimo
                                if (value == minValue) return const Text("");
                                return Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 12));
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              entry.value.length,
                              (i) {
                                dynamic val = entry.value[i];
                                return FlSpot(i.toDouble(), val is num ? val.toDouble() : 0.0);
                              },
                            ),
                            isCurved: true,
                            preventCurveOverShooting: true,
                            dotData: FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
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
                ref.read(plantsControllerProvider(widget.idSensore).notifier).addPlant(
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
   final int idSensore; 

  const EditPlantDialog({Key? key, required this.plant, required this.idSensore}) : super(key: key);

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
                ref.read(plantsControllerProvider(widget.idSensore).notifier).updatePlant(
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


String generatePrompt(String plantName, String species, Map<String, dynamic> processedFeatures) {
  return """
  Analizza le condizioni della pianta **$plantName** di specie **$species** e suggerisci miglioramenti.

  **Dati raccolti nelle ultime 24 ore:**
  ${processedFeatures.entries.map((entry) => "**${entry.key}** -> Media: ${entry.value['media']}, Max: ${entry.value['max']}, Min: ${entry.value['min']}, StdDev: ${entry.value['stdDev']}").join("\n")}

  Basandoti su questi dati, fornisci un'analisi e suggerisci azioni per migliorare la salute della pianta.
  """;
}

Map<String, dynamic> processSensorData(Map<String, dynamic> rawFeatures) {
  Map<String, dynamic> processedData = {};

  rawFeatures.forEach((key, value) {
    if (value is List && value.isNotEmpty) {
      try {
        // Convertiamo tutti i valori a double, ignorando quelli non numerici
        List<double> numericValues = value
            .map((v) => double.tryParse(v.toString())) // Converti a double in modo sicuro
            .where((v) => v != null) // Rimuovi eventuali null
            .map((v) => v!) // Cast sicuro
            .toList();

        if (numericValues.isNotEmpty) {
          double sum = numericValues.reduce((a, b) => a + b);
          double mean = sum / numericValues.length;
          double maxVal = numericValues.reduce(max);
          double minVal = numericValues.reduce(min);
          double variance = numericValues.map((val) => pow(val - mean, 2)).reduce((a, b) => a + b) / numericValues.length;
          double stdDev = sqrt(variance);

          processedData[key] = {
            "media": mean.toStringAsFixed(2),
            "max": maxVal.toStringAsFixed(2),
            "min": minVal.toStringAsFixed(2),
            "stdDev": stdDev.toStringAsFixed(2),
          };
        }
      } catch (e) {
        print("⚠ Errore nel parsing dei dati per la feature '$key': $e");
      }
    }
  });

  return processedData;
}
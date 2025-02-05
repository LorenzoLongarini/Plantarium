import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:open_filex/open_filex.dart';
import 'package:plantairium/common/utils/colors.dart';
import 'package:plantairium/features/plants/ui/plant_detail.dart';
import 'package:plantairium/features/plants/ui/plant_dialog.dart';
import 'package:plantairium/features/report/controller/report_controller.dart';
import 'package:plantairium/features/sensors/controller/sensor_controller.dart';
import 'package:plantairium/features/sensors/services/sensor_service.dart';
import '../controller/plants_controller.dart';
import 'dart:math';

class PlantsView extends ConsumerStatefulWidget {
  final int idSensore;
  final Map<String, dynamic> sensorFeatures;
  final String sensorName;
  final String sensorDate;

  const PlantsView({
    Key? key,
    required this.idSensore,
    required this.sensorFeatures,
    required this.sensorDate,
    required this.sensorName,
  }) : super(key: key);

  @override
  _PlantsViewState createState() => _PlantsViewState();
}

class _PlantsViewState extends ConsumerState<PlantsView> {
  bool showFeatures = false;
  String searchQuery = "";
  String featureSearchQuery = "";

  final TextEditingController featureSearchController = TextEditingController();
  String selectedRange = "Ultime 24 ore";
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final FocusNode featureSearchFocusNode = FocusNode();
  Map<String, bool> inferencing = {};
  List<dynamic>? extractedData = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(plantsControllerProvider(widget.idSensore).notifier)
          .fetchPlants();
    });
  }

  void _requestInference(String featureName) async {
    setState(() {
      inferencing[featureName] = true;
    });

    try {
      // Invio la richiesta di inferenza al backend
      await ref.read(sensorServiceProvider).requestInference(
            widget.idSensore,
            featureName,
          );

      int attempts = 0;
      const maxAttempts = 8; // 8 tentativi da 5 secondi ciascuno
      Map<String, dynamic> updatedSensorData = {};

      while (attempts < maxAttempts) {
        await Future.delayed(Duration(seconds: 5));

        updatedSensorData = await ref
            .read(sensorsControllerProvider.notifier)
            .fetchSensorData(widget.idSensore);

        print(
            "📊 Tentativo ${attempts + 1} - Dati ricevuti per ${featureName}: $updatedSensorData");

        if (updatedSensorData.containsKey('Features') &&
            updatedSensorData['Features']
                .containsKey('Inferenza_$featureName')) {
          break; // Esce dal ciclo se trova i dati
        }
        attempts++;
      }

      if (updatedSensorData.containsKey('Features') &&
          updatedSensorData['Features'].containsKey('Inferenza_$featureName')) {
        var inferenceData =
            updatedSensorData['Features']['Inferenza_$featureName'];
        extractedData = inferenceData;
        // 🔍 Debug: Controlliamo la struttura dei dati ricevuti
        print("📊 Dati inferenza grezzi per ${featureName}: $inferenceData");

        if (extractedData is List && extractedData!.isNotEmpty) {
          setState(() {
            inferencing[featureName] = false;
          });

          print(
              "✅ Dati inferenza processati per '$featureName': $extractedData");
          return;
        }
      }

      print(
          "❌ Errore: Struttura dati inferenza non riconosciuta o vuota per '$featureName'.");
    } catch (e) {
      print("❌ Errore inferenza per '${featureName}': $e");
      setState(() {
        inferencing[featureName] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Map<String, dynamic>>> plantsAsyncValue =
        ref.watch(plantsControllerProvider(widget.idSensore)).map(
              data: (data) => AsyncData(
                (data.value as List)
                    .map((item) => item as Map<String, dynamic>)
                    .toList(),
              ),
              loading: (loading) => const AsyncLoading(),
              error: (error) => AsyncError(error.error, error.stackTrace),
            );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Gestione Piante'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('home'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_rounded, color: Palette.primary),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) =>
                    AddPlantDialog(idSensore: widget.idSensore),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSensorCard(),
              _buildSearchBar(),
              _buildPlantList(plantsAsyncValue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: searchController,
        focusNode: searchFocusNode,
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: "Cerca piante...",
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              searchController.clear();
              setState(() {
                searchQuery = "";
              });
              searchFocusNode.unfocus();
            },
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.grey), // Bordo aggiunto
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.grey), // Bordo aggiunto
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
                color: Colors.blue), // Bordo quando il campo è focalizzato
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        ),
      ),
    );
  }

  Widget _buildPlantList(
      AsyncValue<List<Map<String, dynamic>>> plantsAsyncValue) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      child: plantsAsyncValue.when(
        data: (plants) {
          final filteredPlants = plants.where((plant) {
            final name = plant['Nome'].toString().toLowerCase();
            final specie = plant['Specie']?.toString().toLowerCase() ?? "";
            return name.contains(searchQuery.toLowerCase()) ||
                specie.contains(searchQuery.toLowerCase());
          }).toList();

          if (filteredPlants.isEmpty) {
            return const Center(
              child: Text(
                'Nessuna pianta trovata.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filteredPlants.length,
            itemBuilder: (context, index) {
              final plant = filteredPlants[index];
              return _buildPlantCard(plant, index + 1);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Errore: ${error.toString()}')),
      ),
    );
  }

  Widget _buildSensorCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFDDE8D7),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Nome: ${widget.sensorName}",
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text("Data Installazione: ${widget.sensorDate}",
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  showFeatures = !showFeatures;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child:
                  Text(showFeatures ? "Nascondi Features" : "Mostra Features"),
            ),
          ),
          if (showFeatures) ...[
            const SizedBox(height: 12),
            _buildFeatureCharts(),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureCharts() {
    final Map<String, dynamic> features = widget.sensorFeatures;
    final Map<String, List<double>> allFeatures = {};

    features.forEach((key, value) {
      if (key.toLowerCase() != "id" &&
          key.toLowerCase() != "dateandtime" &&
          key.toLowerCase() != "hour" &&
          key.toLowerCase() != "hout") {
        if (value is List) {
          List<double> numericValues = value
              .whereType<num>() // 🔹 Filtra solo valori numerici
              .map((v) => v.toDouble()) // 🔹 Converte a double
              .toList();

          if (numericValues.isNotEmpty) {
            int dataLimit =
                selectedRange == "Ultimi 30 giorni" ? 24 * 30 + 24 : 24;
            allFeatures[key] = numericValues.length > dataLimit
                ? numericValues.sublist(numericValues.length - dataLimit)
                : numericValues;
          }
        }
      }
    });

    if (allFeatures.isEmpty) {
      return const Center(
        child: Text("Nessuna feature numerica disponibile."),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: DropdownButton<String>(
                  value: selectedRange,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRange = newValue!;
                    });
                  },
                  items: [
                    "Ultime 24 ore",
                    "Ultimi 30 giorni",
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontSize: 16)),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: featureSearchController,
                  focusNode: featureSearchFocusNode,
                  onChanged: (value) {
                    setState(() {
                      featureSearchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Cerca...",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        featureSearchController.clear();
                        setState(() {
                          featureSearchQuery = "";
                        });
                        featureSearchFocusNode.unfocus();
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView(
            children: allFeatures.entries.map((entry) {
              double minValue = entry.value.reduce((a, b) => a < b ? a : b);
              int dataLength = entry.value.length;

              List<double> inferenceValues = [];
              if (allFeatures.containsKey('Inferenza_${entry.key}')) {
                inferenceValues
                    .addAll((extractedData! as List<dynamic>).cast<double>());
                print("📊 Prova Lollo: $inferenceValues");
              }

              List<FlSpot> originalSpots = entry.value
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList();

              List<FlSpot> inferenceSpots = [];
              if (inferenceValues.isNotEmpty) {
                int startIndex =
                    originalSpots.isNotEmpty ? originalSpots.length : 0;

                inferenceSpots = inferenceValues.asMap().entries.map((e) {
                  return FlSpot((startIndex + e.key).toDouble(), e.value);
                }).toList();
              }

              List<LineChartBarData> lineBarsData = [
                // 📊 Linea dei dati reali
                LineChartBarData(
                  color: ((selectedRange == "Ultime 24 ore") &&
                          (inferenceSpots.isNotEmpty))
                      ? Colors.red
                      : Palette.primary,
                  spots: originalSpots,
                  isCurved: true,
                  preventCurveOverShooting: true,
                  dotData: FlDotData(show: false),
                ),
              ];

              // 📊 Aggiungiamo la linea dell'inferenza se i dati sono presenti
              if (inferenceSpots.isNotEmpty) {
                lineBarsData.add(
                  LineChartBarData(
                    color: Colors.red, // 🔴 Linea rossa per l'inferenza
                    spots: [originalSpots.last, ...inferenceSpots],
                    isCurved: true,
                    preventCurveOverShooting: true,
                    dotData: FlDotData(show: false),
                    // dashArray: [5, 5], // 🔹 Linea tratteggiata
                  ),
                );
              }

              return Visibility(
                visible: entry.key.contains(featureSearchQuery),
                child: SizedBox(
                  height: 250,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            inferencing[entry.key] == true
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ) // 🔄 Loading
                                : ElevatedButton(
                                    onPressed: () =>
                                        _requestInference(entry.key),
                                    child: Text(
                                      "Predizione",
                                      style: TextStyle(
                                        color: Palette.primary,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // 🔹 Grafico
                        Expanded(
                          child: LineChart(
                            LineChartData(
                              minX: 0,
                              maxX: (dataLength - 1).toDouble(),
                              titlesData: FlTitlesData(
                                topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      if (value == meta.min ||
                                          value == meta.max) {
                                        return const SizedBox.shrink();
                                      }
                                      int roundedValue = value.round();
                                      if (selectedRange != 'Ultime 24 ore') {
                                        roundedValue =
                                            (roundedValue / 24).round();
                                      }
                                      return Text('${roundedValue}');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      if (value == meta.min ||
                                          value == meta.max) {
                                        return const SizedBox.shrink();
                                      }
                                      if (value == minValue)
                                        return const Text("");
                                      return Text(value.toStringAsFixed(1),
                                          style: const TextStyle(fontSize: 12));
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData:
                                  lineBarsData, // 🔹 Aggiunto inferenza
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlantCard(Map<String, dynamic> plant, int seed) {
    if (seed > 6) {
      seed = seed % 6;
    }
    final imagePath = 'assets/img/plant_$seed.png';

    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Conferma eliminazione'),
              content:
                  const Text('Sei sicuro di voler eliminare questa pianta?'),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      child: Text(
                        'Annulla',
                        style: TextStyle(color: Palette.primary),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text(
                        'Conferma',
                        style: TextStyle(color: Palette.primary),
                      ),
                      onPressed: () {
                        ref
                            .read(plantsControllerProvider(widget.idSensore)
                                .notifier)
                            .deletePlant(plant["Id"], widget.idSensore);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDetailView(
              plant: plant,
              idSensore: widget.idSensore,
              sensorFeatures: widget.sensorFeatures,
              imgPath: imagePath,
            ),
          ),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.all(8),
        child: Card(
          color: Color(0xFFDDE8D7),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 150,
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
              ListTile(
                title: Center(
                    child: Text(plant['Nome'],
                        style: const TextStyle(color: Colors.black))),
                subtitle: Center(child: Text(plant['Specie'] ?? '')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Map<String, dynamic> processSensorData(Map<String, dynamic> rawFeatures) {
  Map<String, dynamic> processedData = {};

  rawFeatures.forEach((key, value) {
    if (value is List && value.isNotEmpty) {
      try {
        // Convertiamo tutti i valori a double, ignorando quelli non numerici
        List<double> numericValues = value
            .map((v) => double.tryParse(
                v.toString())) // Converti a double in modo sicuro
            .where((v) => v != null) // Rimuovi eventuali null
            .map((v) => v!) // Cast sicuro
            .toList();

        if (numericValues.isNotEmpty) {
          double sum = numericValues.reduce((a, b) => a + b);
          double mean = sum / numericValues.length;
          double maxVal = numericValues.reduce(max);
          double minVal = numericValues.reduce(min);
          double variance = numericValues
                  .map((val) => pow(val - mean, 2))
                  .reduce((a, b) => a + b) /
              numericValues.length;
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

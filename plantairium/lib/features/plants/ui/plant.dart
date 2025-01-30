import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:open_filex/open_filex.dart';
import 'package:plantairium/common/utils/colors.dart';
import 'package:plantairium/features/plants/ui/plant_detail.dart';
import 'package:plantairium/features/plants/ui/plant_dialog.dart';
import 'package:plantairium/features/report/controller/report_controller.dart';
import '../controller/plants_controller.dart';
import 'dart:math';

class PlantsView extends ConsumerStatefulWidget {
  final int idSensore;
  final Map<String, dynamic> sensorFeatures;

  const PlantsView(
      {Key? key, required this.idSensore, required this.sensorFeatures})
      : super(key: key);

  @override
  _PlantsViewState createState() => _PlantsViewState();
}

class _PlantsViewState extends ConsumerState<PlantsView> {
  bool showFeatures = false;
  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(plantsControllerProvider(widget.idSensore).notifier)
          .fetchPlants();
    });
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
          Text("ID Sensore: ${widget.idSensore}",
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text("Nome Sensore: Sensore Test",
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
              .map((v) => double.tryParse(v.toString()))
              .where((v) => v != null)
              .map((v) => v!)
              .toList();

          if (numericValues.isNotEmpty) {
            allFeatures[key] = numericValues;
          }
        }
      }
    });

    if (allFeatures.isEmpty) {
      return const Center(
        child: Text("Nessuna feature numerica disponibile."),
      );
    }

    return SizedBox(
      height: 250,
      child: ListView(
        children: allFeatures.entries.map((entry) {
          double minValue = entry.value.reduce((a, b) => a < b ? a : b);
          int dataLength = entry.value.length;

          return SizedBox(
            height: 250,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
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
                                int roundedValue = value.round();
                                if (roundedValue == 0)
                                  return const Text("0:00");
                                if (roundedValue == 12)
                                  return const Text("12:00");
                                if (roundedValue == dataLength - 1)
                                  return const Text("23:00");
                                return const Text("");
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                if (value == minValue) return const Text("");
                                return Text(value.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 12));
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            color: Palette.primary,
                            spots: entry.value
                                .asMap()
                                .entries
                                .where((e) => e.value is num)
                                .map((e) => FlSpot(e.key.toDouble(),
                                    (e.value as num).toDouble()))
                                .toList(),
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

  Widget _buildPlantCard(Map<String, dynamic> plant, int seed) {
    if (seed > 6) {
      seed = seed % 6;
    }
    final imagePath = 'assets/img/plant_$seed.png';

    return GestureDetector(
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

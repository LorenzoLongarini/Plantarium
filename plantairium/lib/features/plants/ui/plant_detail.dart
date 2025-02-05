import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plantairium/common/utils/colors.dart';
import 'package:plantairium/features/plants/ui/plant_dialog.dart';
import 'package:plantairium/features/report/controller/report_controller.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

class PlantDetailView extends ConsumerWidget {
  final Map<String, dynamic> plant;
  final int idSensore;
  final Map<String, dynamic> sensorFeatures;
  final String imgPath;

  const PlantDetailView({
    Key? key,
    required this.plant,
    required this.idSensore,
    required this.sensorFeatures,
    required this.imgPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportController = ref.read(reportControllerProvider.notifier);

    final pdfPath = ref.watch(
        reportControllerProvider.select((reports) => reports[plant['Id']]));
    final isLoading = pdfPath == null &&
        ref.watch(reportControllerProvider).containsKey(plant['Id']);

    return Scaffold(
      appBar: AppBar(
        title: Text(plant['Nome']),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_document, color: Palette.primary),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => EditPlantDialog(
                  plant: plant,
                  idSensore: idSensore,
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                imgPath,
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              plant['Nome'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              plant['Specie'] ?? 'Specie sconosciuta',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),
            Text(
              plant['Descrizione'] ?? 'Nessuna descrizione disponibile',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () async {
                            try {
                              await reportController.generateAndSaveReport(
                                plant['Id'],
                                plant['Nome'],
                                plant['Specie'] ?? 'Specie sconosciuta',
                                sensorFeatures,
                                'Analizza i dati della pianta ${plant['Nome']}',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        '✅ Report generato con successo!')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Errore durante la generazione del report!')),
                              );
                            }
                          },
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.white,
                          ),
                    label: isLoading
                        ? const Text("Generazione in corso...")
                        : const Text("Genera Report"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  if (pdfPath != null) ...[
                    TextButton.icon(
                      onPressed: () {
                        OpenFilex.open(pdfPath);
                      },
                      icon: Icon(
                        Icons.open_in_new,
                        color: Palette.primary,
                      ),
                      label: Text(
                        "Apri Report",
                        style: TextStyle(color: Palette.primary),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Share.shareXFiles([XFile(pdfPath)],
                            text:
                                "Ecco il report della pianta ${plant['Nome']}");
                      },
                      icon: Icon(
                        Icons.share,
                        color: Palette.primary,
                      ),
                      label: Text(
                        "Condividi Report",
                        style: TextStyle(color: Palette.primary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

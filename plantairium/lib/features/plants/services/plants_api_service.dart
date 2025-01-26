import 'dart:async';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plantairium/models/ModelProvider.dart';

final plantsAPIServiceProvider = Provider<PlantsAPIService>((ref) {
  final service = PlantsAPIService();
  return service;
});

class PlantsAPIService {
  PlantsAPIService();

  Future<List<Plant>> getPlants() async {
    try {
      final request = ModelQueries.list(Plant.classType);
      final response = await Amplify.API.query(request: request).response;

      final plants = response.data?.items;
      if (plants == null) {
        safePrint('getPlants errors: ${response.errors}');
        return const [];
      }
      // trips.sort(
      //   (a, b) =>
      //       a!.startDate.getDateTime().compareTo(b!.startDate.getDateTime()),
      // );
      return plants
          .map((e) => e as Plant)
          // .where(
          //   (element) => element.endDate.getDateTime().isAfter(DateTime.now()),
          // )
          .toList();
    } on Exception catch (error) {
      safePrint('getPlants failed: $error');

      return const [];
    }
  }

  // Future<List<Plant>> getPastTrips() async {
  //   try {
  //     final request = ModelQueries.list(Plant.classType);
  //     final response = await Amplify.API.query(request: request).response;

  //     final plants = response.data?.items;
  //     if (plants == null) {
  //       safePrint('getPastPlants errors: ${response.errors}');
  //       return const [];
  //     }
  //     // plants.sort(
  //     //   (a, b) =>
  //     //       a!.startDate.getDateTime().compareTo(b!.startDate.getDateTime()),
  //     // );
  //     return plants
  //         .map((e) => e as Plant)
  //         // .where(
  //         //   (element) => element.endDate.getDateTime().isBefore(DateTime.now()),
  //         // )
  //         .toList();
  //   } on Exception catch (error) {
  //     safePrint('getPastPlants failed: $error');

  //     return const [];
  //   }
  // }

  Future<void> addPlant(Plant plant) async {
    try {
      final request = ModelMutations.create(plant);
      final response = await Amplify.API.mutate(request: request).response;

      final createdPlant = response.data;
      if (createdPlant == null) {
        safePrint('addPlant errors: ${response.errors}');
        return;
      }
    } on Exception catch (error) {
      safePrint('addPlant failed: $error');
    }
  }

  Future<void> deletePlant(Plant plant) async {
    try {
      await Amplify.API
          .mutate(
            request: ModelMutations.delete(plant),
          )
          .response;
    } on Exception catch (error) {
      safePrint('deletePlant failed: $error');
    }
  }

  Future<void> updatePlant(Plant updatedPlant) async {
    try {
      await Amplify.API
          .mutate(
            request: ModelMutations.update(updatedPlant),
          )
          .response;
    } on Exception catch (error) {
      safePrint('updatePlant failed: $error');
    }
  }

  Future<Plant> getPlant(String plantId) async {
    try {
      final request = ModelQueries.get(
        Plant.classType,
        PlantModelIdentifier(id: plantId),
      );
      final response = await Amplify.API.query(request: request).response;

      final plant = response.data!;
      return plant;
    } on Exception catch (error) {
      safePrint('getPlant failed: $error');
      rethrow;
    }
  }
}

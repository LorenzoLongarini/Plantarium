import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plantairium/common/navigation/router/routes.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.goNamed(AppRoute.home.name);
          },
        ),
      ),
      body: const Center(
        child: Text('Sensor Page'),
      ),
    );
  }
}
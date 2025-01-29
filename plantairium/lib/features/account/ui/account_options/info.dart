import 'package:flutter/material.dart';

class Info extends StatelessWidget {
  const Info({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Informazioni di Sistema',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Versione App: 1.0.0'),
            Text('Versione Flutter: 3.3.0'),
            Text('Sistema Operativo: Android/iOS'),
            Text('Sviluppatore: Plantairium Team'),
          ],
        ),
      ),
    );
  }
}
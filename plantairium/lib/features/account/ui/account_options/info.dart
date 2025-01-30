import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:plantairium/common/utils/colors.dart';
import 'package:platform/platform.dart';

class Info extends StatefulWidget {
  const Info({super.key});

  @override
  _InfoState createState() => _InfoState();
}

class _InfoState extends State<Info> {
  String appVersion = '';
  String flutterVersion = '3.3.0'; // Può essere aggiornata manualmente
  String operatingSystem = '';
  String developer = 'Plantairium Team';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    _initPlatformInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = info.version;
    });
  }

  void _initPlatformInfo() {
    final platform = LocalPlatform();
    setState(() {
      operatingSystem = platform.operatingSystem;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Sistema'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard('Versione App', appVersion, Icons.info),
            _buildCard('Versione Flutter', flutterVersion, Icons.code),
            _buildCard('Sistema Operativo', operatingSystem, Icons.phone_android),
            _buildCard('Sviluppatore', developer, Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String value, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Palette.primary, size: 30),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}

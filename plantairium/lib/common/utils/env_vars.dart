import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvVars {
  static String get username => dotenv.get('USERNAME');
  static String get password => dotenv.get('PASSWORD');
  static String get sensorsApi => dotenv.get('SENSORS_API');
  static String get plantsApi => dotenv.get('PLANTS_API');
}

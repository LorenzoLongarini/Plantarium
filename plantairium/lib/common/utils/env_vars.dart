import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvVars {
  static String get username => dotenv.get('USERNAME');
  static String get password => dotenv.get('PASSWORD');
  static String get lambdaApi => dotenv.get('LAMBDA_API');
  static String get copilotKey => dotenv.get('COPILOT_KEY');
}

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plantairium/amplifyconfiguration.dart';
import 'package:plantairium/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plantairium/models/ModelProvider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await _configureAmplify();
    await dotenv.load(fileName: ".env");
  } on AmplifyAlreadyConfiguredException {
    debugPrint('Amplify configuration failed.');
  }

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugins([
      AmplifyAuthCognito(),
      AmplifyAPI(
        // modelProvider: ModelProvider.instance,
        // subscriptionOptions: GraphQLSubscriptionOptions(
        //   retryOptions: RetryOptions(
        //     delayFactor: const Duration(milliseconds: 300),
        //     maxAttempts: double.maxFinite.toInt(),
        //   ),
        // ),
      ),
      // AmplifyStorageS3(),
    ]);
    await Amplify.configure(amplifyconfig);
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plantairium/common/navigation/router/router.dart';

final loginAPIServiceProvider = Provider.autoDispose<LoginAPIService>((ref) {
  final service = LoginAPIService();
  return service;
});

class LoginAPIService {
  LoginAPIService();

  Future<void> onSignUp(SignupData data) async {
    await Amplify.Auth.signUp(
      username: data.name!,
      password: data.password!,
      options: SignUpOptions(
        userAttributes: {
          AuthUserAttributeKey.email: data.name!,
        },
      ),
    );
  }

Future<void> onLogin(LoginData data) async {
  final session = await Amplify.Auth.fetchAuthSession();

  if (session.isSignedIn) {
    await Amplify.Auth.signOut();
    final signInResult = await Amplify.Auth.signIn(
      username: data.name,
      password: data.password,
    );
    if (signInResult.isSignedIn) {
      authNotifier.setSignedIn(true);
    }
  } else {
    final signInResult = await Amplify.Auth.signIn(
      username: data.name,
      password: data.password,
    );
    if (signInResult.isSignedIn) {
      authNotifier.setSignedIn(true);
    }
  }
}

  Future<void> onRecoverPassword(String email) async {
    await Amplify.Auth.resetPassword(username: email);
  }

  Future<void> onConfirmRecover(
      {required LoginData data, required String code}) async {
    await Amplify.Auth.confirmResetPassword(
      username: data.name,
      newPassword: data.password,
      confirmationCode: code,
    );
  }

  Future<void> verifyCode({
    required LoginData data,
    required String code,
  }) async {
    final res = await Amplify.Auth.confirmSignUp(
      username: data.name,
      confirmationCode: code,
    );
    if (res.isSignUpComplete) {
      final signInResult = await Amplify.Auth.signIn(
        username: data.name,
        password: data.password,
      );
      if (signInResult.isSignedIn) {
        authNotifier.setSignedIn(true);
      }
    }
  }

  Future<void> resendCode(SignupData data) async {
    await Amplify.Auth.resendSignUpCode(username: data.name!);
  }
}

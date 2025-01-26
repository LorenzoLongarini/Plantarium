import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      Amplify.Auth.signOut().then((value) async {
        return await Amplify.Auth.signIn(
          username: data.name,
          password: data.password,
        );
      }).then((value) => null);
    } else {
      await Amplify.Auth.signIn(
        username: data.name,
        password: data.password,
      );
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
      await Amplify.Auth.signIn(username: data.name, password: data.password);
    }
  }

  Future<void> resendCode(SignupData data) async {
    await Amplify.Auth.resendSignUpCode(username: data.name!);
  }
}

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:plantairium/features/login/services/login_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_controller.g.dart';

@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() async {}

  Future<String?> onSignUp(SignupData data) async {
    try {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        final loginService = ref.read(loginAPIServiceProvider);
        await loginService.onSignUp(data);
      });
      return '';
    } on AuthException catch (e) {
      return 'Error signing up: ${e.message}';
    }
  }

  Future<String?> onLogin(LoginData data) async {
    try {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        final loginService = ref.read(loginAPIServiceProvider);

        await loginService.onLogin(data);
      });
      return '';
    } on AuthException catch (e) {
      return 'Error signing up: ${e.message}';
    }
  }

  Future<String?> onRecoverPassword(String email) async {
    try {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        final loginService = ref.read(loginAPIServiceProvider);

        await loginService.onRecoverPassword(email);
      });
      return '';
    } on AuthException catch (e) {
      return 'Error signing up: ${e.message}';
    }
  }

  Future<String?> onConfirmRecover(
      {required LoginData data, required String code}) async {
    try {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        final loginService = ref.read(loginAPIServiceProvider);

        await loginService.onConfirmRecover(data: data, code: code);
      });
      return '';
    } on AuthException catch (e) {
      return 'Error signing up: ${e.message}';
    }
  }

  Future<String?> verifyCode({
    required LoginData data,
    required String code,
  }) async {
    try {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        final loginService = ref.read(loginAPIServiceProvider);

        await loginService.verifyCode(data: data, code: code);
      });
      return '';
    } on AuthException catch (e) {
      return 'Error signing up: ${e.message}';
    }
  }

  Future<String?> resendCode(SignupData data) async {
    state = const AsyncValue.loading();
    try {
      state = await AsyncValue.guard(() async {
        final loginService = ref.read(loginAPIServiceProvider);

        await loginService.resendCode(data);
      });
      return '';
    } on AuthException catch (e) {
      return 'Error signing up: ${e.message}';
    }
  }
}

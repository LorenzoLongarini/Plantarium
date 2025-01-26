import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:plantairium/common/navigation/router/routes.dart';
import 'package:plantairium/common/utils/colors.dart';
import 'package:plantairium/common/utils/env_vars.dart';
import 'package:plantairium/features/login/controller/login_controller.dart';

class Login extends ConsumerStatefulWidget {
  const Login({
    super.key,
  });

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      key: widget.key,
      savedEmail: EnvVars.username,
      savedPassword: EnvVars.password,
      theme: LoginTheme(
        pageColorLight: Palette.white,
        cardTopPosition: MediaQuery.of(context).size.height / 5,
        inputTheme: InputDecorationTheme(
          fillColor: Palette.lightGreen,
          labelStyle: TextStyle(
            color: Palette.primary,
          ),
          prefixIconColor: Palette.primary,
          suffixIconColor: Palette.primary,
        ),
        cardTheme: CardTheme(
          color: Palette.white,
          shadowColor: Palette.white,
          surfaceTintColor: Palette.white,
        ),
      ),
      headerWidget: Align(
        alignment: Alignment.center,
        child: SizedBox(
          height: 220,
          child: Lottie.asset("assets/lottie/login.json"),
        ),
      ),
      onLogin: (LoginData data) {
        return ref.read(loginControllerProvider.notifier).onLogin(data);
      },
      onSignup: (SignupData data) {
        return ref.read(loginControllerProvider.notifier).onSignUp(data);
      },
      onConfirmSignup: (code, data) async {
        return ref.read(loginControllerProvider.notifier).verifyCode(
              data: data,
              code: code,
            );
      },
      onRecoverPassword: (String data) {
        return ref
            .read(loginControllerProvider.notifier)
            .onRecoverPassword(data);
      },
      onConfirmRecover: (code, data) async {
        return ref
            .read(loginControllerProvider.notifier)
            .onConfirmRecover(code: code, data: data);
      },
      onResendCode: (data) async {
        return ref.read(loginControllerProvider.notifier).resendCode(data);
      },
      onSubmitAnimationCompleted: () async {
        final session = await Amplify.Auth.fetchAuthSession();

        session.isSignedIn
            ? context.goNamed(AppRoute.home.name)
            : context.goNamed(
                AppRoute.login.name,
              );
      },
    );
  }
}

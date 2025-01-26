import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plantairium/common/navigation/router/routes.dart';
import 'package:plantairium/common/ui/base.dart';
import 'package:plantairium/features/account/ui/account_options/my_account.dart';
import 'package:plantairium/features/chatbot/ui/chatbot.dart';
import 'package:plantairium/features/login/ui/login.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      redirect: (context, state) async {
        final user = await Amplify.Auth.fetchAuthSession();
        if (user.isSignedIn) {
          return null;
        } else {
          return '/login';
        }
      },
      path: '/',
      name: AppRoute.home.name,
      builder: (BuildContext context, GoRouterState state) {
        return const Base();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'myaccount',
          name: AppRoute.myaccount.name,
          builder: (BuildContext context, GoRouterState state) {
            Map<AuthUserAttributeKey, String?> userInfos =
                state.extra as Map<AuthUserAttributeKey, String?>;
            return MyAccount(
              userInfos: userInfos,
            );
          },
        )
      ],
    ),
    GoRoute(
      path: '/llm',
      builder: (BuildContext context, GoRouterState state) {
        return const SizedBox();
      },
    ),
    GoRoute(
      path: '/chatbot',
      name: AppRoute.chatbot.name,
      builder: (BuildContext context, GoRouterState state) {
        return const Chatbot();
      },
    ),
    GoRoute(
      path: '/login',
      name: AppRoute.login.name,
      builder: (BuildContext context, GoRouterState state) {
        return Login(key: UniqueKey());
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(state.error.toString()),
    ),
  ),
);

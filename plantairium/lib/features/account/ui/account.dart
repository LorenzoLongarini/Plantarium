import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plantairium/common/navigation/router/routes.dart';
import 'package:plantairium/common/services/system_service.dart';
import 'package:plantairium/common/ui/custom_widgets/dialog/custom_alert_dialog.dart';
import 'package:plantairium/common/ui/custom_widgets/list_tile/list_tile.dart';
import 'package:plantairium/features/account/controller/account_controller.dart';

class Account extends ConsumerStatefulWidget {
  const Account({super.key});

  @override
  ConsumerState<Account> createState() => _AccountState();
}

class _AccountState extends ConsumerState<Account> {
  // AuthUser? _user;
  bool isDarkMode =
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
  bool systemMode = false;
  @override
  void initState() {
    super.initState();
    //FIXME: dont use multiple providers in same widget
    bool systemMode = ref.read(systemServiceProvider.notifier).state;
  }

  @override
  Widget build(BuildContext context) {
    final currUserInfos = ref.watch(accountControllerProvider);

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Account'),
          actions: <Widget>[
            IconButton(
              icon: Icon(systemMode ? Icons.brightness_2 : Icons.brightness_4),
              onPressed: () {
                setState(() {
                  systemMode = !systemMode;
                  ref.read(systemServiceProvider.notifier).state = systemMode;
                });
              },
            ),
          ],
        ),
        body: switch (currUserInfos) {
          AsyncData(:final value) => Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const CircleAvatar(
                      radius: 70,
                      backgroundColor: Color.fromARGB(255, 64, 120, 27),
                      child: CircleAvatar(
                        radius: 65,
                        backgroundImage:
                            AssetImage('assets/img/default-avatar.jpg'),
                      ),
                    ),
                    value[AuthUserAttributeKey.nickname] != null
                        ? Text(
                            value[AuthUserAttributeKey.nickname]!,
                            style: const TextStyle(
                                fontSize: 10,
                                color: Color.fromARGB(255, 210, 210, 210)),
                          )
                        : const SizedBox.shrink(),
                    value[AuthUserAttributeKey.email] != null
                        ? Text(
                            value[AuthUserAttributeKey.email]!,
                            style: const TextStyle(
                                fontSize: 10,
                                color: Color.fromARGB(255, 210, 210, 210)),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomListTile(
                      icon: Icons.person,
                      text: 'My Profile',
                      onTap: () => context.goNamed(AppRoute.myaccount.name,
                          extra: value),
                    ),
                    const CustomListTile(
                      icon: Icons.settings,
                      text: 'Settings',
                    ),
                    const CustomListTile(
                      icon: Icons.chat_bubble,
                      text: 'FAQs',
                    ),
                    const CustomListTile(
                      icon: Icons.info,
                      text: 'Info',
                    ),
                    MaterialButton(
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => CustomAlertDialog(
                            title: 'Sei sicuro di voler effettuare il logout?',
                            onPressed: () => Amplify.Auth.signOut()
                                .then(
                                  (value) => {
                                    context.goNamed(AppRoute.login.name),
                                  },
                                )
                                .then((_) => false),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          AsyncError(:final error) => Text(
              error.toString(),
            ),
          _ => const Center(
              child: CircularProgressIndicator(),
            ),
        }

        // AccountOptions.values.map((e) => null)
        // ListView.separated()
        );
  }
}

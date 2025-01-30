import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plantairium/common/navigation/router/routes.dart';
import 'package:plantairium/common/services/system_service.dart';
import 'package:plantairium/common/ui/custom_widgets/dialog/custom_alert_dialog.dart';
import 'package:plantairium/common/ui/custom_widgets/list_tile/list_tile.dart';
import 'package:plantairium/common/utils/colors.dart';
import 'package:plantairium/features/account/controller/account_controller.dart';
import 'package:plantairium/features/account/ui/account_options/faqs.dart';
import 'package:plantairium/features/account/ui/account_options/info.dart';
import 'package:plantairium/features/account/ui/account_options/my_account.dart';

class Account extends ConsumerStatefulWidget {
  const Account({super.key});

  @override
  ConsumerState<Account> createState() => _AccountState();
}

class _AccountState extends ConsumerState<Account> {
  @override
  Widget build(BuildContext context) {
    final currUserInfos = ref.watch(accountControllerProvider);
    final systemProvider = ref.watch(systemServiceProvider);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Account'),
        actions: [
          IconButton(
            icon: Icon(systemProvider ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              ref.read(systemServiceProvider.notifier).state = !systemProvider;
            },
          ),
        ],
      ),
      body: currUserInfos.when(
        data: (value) => Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                const CircleAvatar(
                  radius: 90,
                  backgroundColor: Color.fromARGB(255, 64, 120, 27),
                  backgroundImage: AssetImage('assets/img/avatarlollo.png'),
                ),
                value[AuthUserAttributeKey.nickname] != null
                    ? Text(
                        value[AuthUserAttributeKey.nickname]!,
                        style: const TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 210, 210, 210)),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 8),
                value[AuthUserAttributeKey.email] != null
                    ? Text(
                        value[AuthUserAttributeKey.email]!,
                        style: const TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 145, 145, 145)),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            Column(
              children: [
                CustomListTile(
                  icon: Icons.person,
                  iconColor: Palette.primary,
                  text: 'My Profile',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyAccount(userInfos: value)),
                  ),
                ),
                const SizedBox(height: 20), // Maggiore distanza tra le opzioni
                CustomListTile(
                  icon: Icons.chat_bubble,
                  iconColor: Palette.primary,
                  text: 'FAQs',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FAQ()),
                  ),
                ),
                const SizedBox(height: 20),
                CustomListTile(
                  icon: Icons.info,
                  iconColor: Palette.primary,
                  text: 'Info',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Info()),
                  ),
                ),
                const SizedBox(height: 30),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Text(error.toString()),
      ),
    );
  }
}

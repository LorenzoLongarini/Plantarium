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

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Account'),
      ),
      body: currUserInfos.when(
        data: (value) => Column(
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
                    backgroundImage: AssetImage('assets/img/default-avatar.jpg'),
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
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  MyAccount(userInfos: value)),
                  ),
                  // context.goNamed(AppRoute.myaccount.name,
                  //     extra: value),
                ),
                CustomListTile(
                  icon: Icons.chat_bubble,
                  text: 'FAQs',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FAQ()),
                  ),
                ),
                CustomListTile(
                  icon: Icons.info,
                  text: 'Info',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Info()),
                  ),
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
                        onPressed: () => Amplify.Auth.signOut().then(
                          (value) => {
                            context.goNamed(AppRoute.login.name),
                          },
                        ).then((_) => false),
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

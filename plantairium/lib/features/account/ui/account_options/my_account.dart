import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plantairium/common/navigation/router/routes.dart';
import 'package:plantairium/common/ui/custom_widgets/button/custom_material_button.dart';
import 'package:plantairium/common/ui/custom_widgets/text_field/textfield.dart';
import 'package:plantairium/features/account/controller/account_controller.dart';
import 'package:plantairium/common/utils/colors.dart';

class MyAccount extends StatelessWidget {
  const MyAccount({
    super.key,
    required this.userInfos,
  });
  final Map<AuthUserAttributeKey, String?> userInfos;

  @override
  Widget build(BuildContext context) {
    TextEditingController nicknameController =
        TextEditingController(text: userInfos[AuthUserAttributeKey.nickname]);
    TextEditingController nameController =
        TextEditingController(text: userInfos[AuthUserAttributeKey.name]);
    TextEditingController surnameController =
        TextEditingController(text: userInfos[AuthUserAttributeKey.familyName]);
    TextEditingController emailController =
        TextEditingController(text: userInfos[AuthUserAttributeKey.email]);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Il Mio Account'),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  const CircleAvatar(
                    radius: 90,
                    backgroundColor: Color.fromARGB(255, 64, 120, 27),
                    backgroundImage: AssetImage('assets/img/avatarlollo.png'),
                  ),
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              CustomTextField(
                labelText: 'Nickname',
                prefixIcon: const Icon(Icons.person),
                backgroundColor: Palette.lightGreen,
                controller: nicknameController,
                onChanged: (value) =>
                    userInfos[AuthUserAttributeKey.nickname] = value,
              ),
              CustomTextField(
                labelText: 'Nome',
                prefixIcon: const Icon(Icons.person),
                backgroundColor: Palette.lightGreen,
                controller: nameController,
                onChanged: (value) =>
                    userInfos[AuthUserAttributeKey.name] = value,
              ),
              CustomTextField(
                labelText: 'Cognome',
                prefixIcon: const Icon(Icons.person),
                backgroundColor: Palette.lightGreen,
                controller: surnameController,
                onChanged: (value) =>
                    userInfos[AuthUserAttributeKey.familyName] = value,
              ),
              CustomTextField(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                backgroundColor: Palette.lightGreen,
                controller: emailController,
                onChanged: (value) =>
                    userInfos[AuthUserAttributeKey.email] = value,
              ),
              const SizedBox(height: 30),
              Center(
                child: Consumer(
                  builder: (context, ref, child) {
                    return CustomMaterialButton(
                      title: 'Modifica',
                      onPressed: () {
                        userInfos.forEach((key, value) async {
                          try {
                            ref
                                .read(accountControllerProvider.notifier)
                                .updateUserInfos(key: key, value: value);
                          } on AuthException catch (e) {
                            safePrint(e);
                          }
                        });
                        context.goNamed(AppRoute.home.name);
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ));
  }
}
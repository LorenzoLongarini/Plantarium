import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plantairium/common/navigation/router/routes.dart';
import 'package:plantairium/common/ui/custom_widgets/button/custom_material_button.dart';
import 'package:plantairium/common/ui/custom_widgets/text_field/textfield.dart';
import 'package:plantairium/features/account/controller/account_controller.dart';

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
    TextEditingController phoneController = TextEditingController(
        text: userInfos[AuthUserAttributeKey.phoneNumber]);
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Account'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 70,
                backgroundColor: Color.fromARGB(255, 64, 120, 27),
                child: CircleAvatar(
                  radius: 65,
                  backgroundImage: AssetImage('assets/img/default-avatar.jpg'),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomTextField(
                    labelText: 'Nickname',
                    prefixIcon: const Icon(Icons.person),
                    backgroundColor: const Color.fromARGB(255, 244, 244, 244),
                    controller: nicknameController,
                    onChanged: (value) =>
                        userInfos[AuthUserAttributeKey.nickname] = value,
                  ),
                  CustomTextField(
                    labelText: 'Nome',
                    prefixIcon: const Icon(Icons.person),
                    backgroundColor: const Color.fromARGB(255, 244, 244, 244),
                    controller: nameController,
                    onChanged: (value) =>
                        userInfos[AuthUserAttributeKey.name] = value,
                  ),
                  CustomTextField(
                    labelText: 'Cognome',
                    prefixIcon: const Icon(Icons.person),
                    backgroundColor: const Color.fromARGB(255, 244, 244, 244),
                    controller: surnameController,
                    onChanged: (value) =>
                        userInfos[AuthUserAttributeKey.familyName] = value,
                  ),
                  CustomTextField(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    backgroundColor: const Color.fromARGB(255, 244, 244, 244),
                    controller: emailController,
                    onChanged: (value) =>
                        userInfos[AuthUserAttributeKey.email] = value,
                  ),
                  CustomTextField(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Icons.phone),
                    backgroundColor: const Color.fromARGB(255, 244, 244, 244),
                    controller: phoneController,
                    onChanged: (value) =>
                        userInfos[AuthUserAttributeKey.phoneNumber] = value,
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Consumer(
                builder: (context, ref, child) {
                  return CustomMaterialButton(
                    title: 'Conferma',
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
              )
            ],
          ),
        ));
  }
}

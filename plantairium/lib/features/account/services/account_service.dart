import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final accountAPIServiceProvider =
    Provider.autoDispose<AccountAPIService>((ref) {
  final service = AccountAPIService();
  return service;
});

class AccountAPIService {
  AccountAPIService();

  Future<Map<AuthUserAttributeKey, String>> getCurrentUserInfos() async {
    final userAttributes = await Amplify.Auth.fetchUserAttributes();
    final Map<AuthUserAttributeKey, String> userInfos = {};

    for (final values in userAttributes) {
      if (values.userAttributeKey.key == 'email_verified' ||
          values.userAttributeKey.key == 'sub') {
      } else {
        userInfos[values.userAttributeKey] = values.value;
      }
    }
    return userInfos;
  }

  Future<void> updateUserAttribute(
      AuthUserAttributeKey key, String value) async {
    await Amplify.Auth.updateUserAttribute(userAttributeKey: key, value: value);
  }
}

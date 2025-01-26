import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:plantairium/common/services/system_service.dart';
import 'package:plantairium/features/account/services/account_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_controller.g.dart';

@riverpod
class AccountController extends _$AccountController {
  Future<Map<AuthUserAttributeKey, String>> _fetchUserInfos() async {
    final accountService = ref.read(accountAPIServiceProvider);
    final accountInfos = await accountService.getCurrentUserInfos();
    return accountInfos;
  }

  @override
  FutureOr<Map<AuthUserAttributeKey, String>> build() async {
    return _fetchUserInfos();
  }

  Future<void> updateUserInfos({
    required AuthUserAttributeKey key,
    String? value,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final messagesRepository = ref.read(accountAPIServiceProvider);

      await messagesRepository.updateUserAttribute(key, value ?? '');

      return _fetchUserInfos();
    });
  }

  bool switchSystemTheme() {
    final systemProvider = ref.read(systemServiceProvider);
    return systemProvider;
  }
}

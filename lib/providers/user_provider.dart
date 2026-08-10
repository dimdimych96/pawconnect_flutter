import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserState {
  final String ownerName;
  final String ownerAvatar;
  final bool pushNotificationsEnabled;
  final bool isSimulatingBreach;

  const UserState({
    this.ownerName = 'Алексей Иванов',
    this.ownerAvatar = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
    this.pushNotificationsEnabled = true,
    this.isSimulatingBreach = false,
  });

  UserState copyWith({
    String? ownerName,
    String? ownerAvatar,
    bool? pushNotificationsEnabled,
    bool? isSimulatingBreach,
  }) {
    return UserState(
      ownerName: ownerName ?? this.ownerName,
      ownerAvatar: ownerAvatar ?? this.ownerAvatar,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      isSimulatingBreach: isSimulatingBreach ?? this.isSimulatingBreach,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(const UserState());

  void updateProfile(String name, String avatar) {
    state = state.copyWith(ownerName: name, ownerAvatar: avatar);
  }

  void togglePushNotifications(bool enabled) {
    state = state.copyWith(pushNotificationsEnabled: enabled);
  }

  void toggleSimulateBreach([bool? value]) {
    state = state.copyWith(isSimulatingBreach: value ?? !state.isSimulatingBreach);
  }
}

final userNotifierProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});

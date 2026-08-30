import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_model.dart';
import '../services/auth_service.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final UserAuthModel? currentUser;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = true,
    this.isLoading = false,
    this.currentUser,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    UserAuthModel? currentUser,
    bool clearCurrentUser = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      currentUser: clearCurrentUser ? null : (currentUser ?? this.currentUser),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService)
      : super(
          AuthState(
            isAuthenticated: true,
            currentUser: AuthService.defaultUser,
          ),
        ) {
    checkSession();
  }

  Future<void> checkSession() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);

    final savedUser = await _authService.getCurrentUser();
    final savedTokens = await _authService.getSavedTokens();

    if (!mounted) return;

    if (savedTokens != null && !savedTokens.isExpired) {
      state = state.copyWith(
        isAuthenticated: true,
        currentUser: savedUser ?? AuthService.defaultUser,
        isLoading: false,
      );
    } else if (savedTokens != null && savedTokens.isExpired) {
      state = state.copyWith(
        isAuthenticated: false,
        clearCurrentUser: true,
        isLoading: false,
      );
    } else {
      // If no stored tokens yet, keep active for initial launch but allow logout
      state = state.copyWith(
        isAuthenticated: state.isAuthenticated,
        currentUser: savedUser ?? AuthService.defaultUser,
        isLoading: false,
      );
    }
  }

  Future<bool> login({required String email, required String password}) async {
    if (!mounted) return false;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _authService.login(email: email, password: password);
      if (!mounted) return false;
      state = state.copyWith(
        isAuthenticated: true,
        currentUser: response.user,
        isLoading: false,
      );
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ошибка входа. Проверьте email и пароль.',
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (!mounted) return false;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      if (!mounted) return false;
      state = state.copyWith(
        isAuthenticated: true,
        currentUser: response.user,
        isLoading: false,
      );
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ошибка регистрации. Попробуйте снова.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true);
    await _authService.logout();
    if (!mounted) return;
    state = state.copyWith(
      isAuthenticated: false,
      clearCurrentUser: true,
      isLoading: false,
    );
  }

  void updateProfile(String name, String avatarUrl) async {
    if (state.currentUser == null) return;
    final updated = state.currentUser!.copyWith(
      name: name,
      avatarUrl: avatarUrl,
    );
    await _authService.storage.saveUser(updated);
    if (!mounted) return;
    state = state.copyWith(currentUser: updated);
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final service = ref.watch(authServiceProvider);
  return AuthNotifier(service);
});

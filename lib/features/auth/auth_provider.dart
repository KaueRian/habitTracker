import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart' show isFirebaseInitialized;

class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isGuest; // Simulated guest mode if Firebase not initialized

  AuthState({this.user, this.isLoading = false, this.errorMessage, this.isGuest = false});

  AuthState copyWith({User? user, bool? isLoading, String? errorMessage, bool? isGuest}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  FirebaseAuth? _auth;

  AuthNotifier() : super(AuthState()) {
    if (isFirebaseInitialized) {
      try {
        _auth = FirebaseAuth.instance;
        state = AuthState(user: _auth!.currentUser);
        _auth!.authStateChanges().listen((user) {
          state = AuthState(user: user, isGuest: user == null ? state.isGuest : false);
        });
      } catch (e) {
        debugPrint('FirebaseAuth init error, running in simulated mode: $e');
        _auth = null;
      }
    } else {
      debugPrint('Firebase not initialized. Auth running in simulated/guest mode.');
    }
  }

  Future<void> signInAnonymously() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    if (_auth != null) {
      try {
        await _auth!.signInAnonymously();
        return;
      } catch (e) {
        debugPrint('Anonymous sign-in failed, falling back to guest: $e');
      }
    }
    // Fallback: simulated guest mode
    state = state.copyWith(isLoading: false, isGuest: true);
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    if (_auth != null) {
      try {
        await _auth!.signInWithEmailAndPassword(email: email, password: password);
        return;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          state = state.copyWith(isLoading: false, errorMessage: 'E-mail ou senha incorretos.');
        } else {
          state = state.copyWith(isLoading: false, errorMessage: e.message ?? 'Erro ao fazer login.');
        }
        return;
      } catch (e) {
        debugPrint('Email sign-in failed, falling back to guest: $e');
      }
    }
    // Offline/unconfigured fallback for testing UI
    state = state.copyWith(isLoading: false, isGuest: true);
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    if (_auth != null) {
      try {
        await _auth!.createUserWithEmailAndPassword(email: email, password: password);
        return;
      } on FirebaseAuthException catch (e) {
        state = state.copyWith(isLoading: false, errorMessage: e.message ?? 'Erro ao criar conta.');
        return;
      } catch (e) {
        debugPrint('Email sign-up failed, falling back to guest: $e');
      }
    }
    state = state.copyWith(isLoading: false, isGuest: true);
  }

  Future<void> signOut() async {
    if (state.isGuest || _auth == null) {
      state = AuthState(user: null, isGuest: false);
    } else {
      await _auth!.signOut();
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true);
    try {
      if (state.isGuest || _auth == null) {
        state = AuthState(user: null, isGuest: false);
      } else {
        await _auth!.currentUser?.delete();
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erro ao excluir conta. Faça login novamente.');
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

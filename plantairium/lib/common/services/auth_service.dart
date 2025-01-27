import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

class AuthNotifier extends ChangeNotifier {
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  /// Controlla la sessione e aggiorna lo stato
  Future<void> checkSession() async {
    final session = await Amplify.Auth.fetchAuthSession();
    _isSignedIn = session.isSignedIn;
    notifyListeners();  // rinfresca chi osserva
  }

  /// Segna come loggato
  void setSignedIn(bool value) {
    _isSignedIn = value;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  int? _id;
  String? _nome;
  String? _email;

  int? get id => _id;
  String? get nome => _nome;
  String? get email => _email;

  bool get isLoggedIn => _id != null;

  /// Define os dados do usuário logado
  void setUserData({
    required int id,
    required String nome,
    required String email,
  }) {
    _id = id;
    _nome = nome;
    _email = email;
    notifyListeners();
  }

  /// Limpa dados do usuário (logout)
  void clearUserData() {
    _id = null;
    _nome = null;
    _email = null;
    notifyListeners();
  }
}

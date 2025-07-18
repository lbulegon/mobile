
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _nome = '';
  String _email = '';
  String _telefone = '';
  int _motoboyId = 0;

  // Getters
  String get nome => _nome;
  String get email => _email;
  String get telefone => _telefone;
  int get motoboyId => _motoboyId;

  // Define os dados do usuário
  void setUser(String nome, String email, String telefone, int motoboyId) {
    _nome = nome;
    _email = email;
    _telefone = telefone;
    _motoboyId = motoboyId;
    notifyListeners();
  }

  // Limpa os dados do usuário
  void clearUserData() {
    _nome = '';
    _email = '';
    _telefone = '';
    _motoboyId = 0;
    notifyListeners();
  }
}

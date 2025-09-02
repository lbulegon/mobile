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
    print('👤 [UserProvider] Definindo dados do usuário...');
    print('🆔 [UserProvider] ID: $id');
    print('📛 [UserProvider] Nome: $nome');
    print('📧 [UserProvider] Email: $email');
    
    _id = id;
    _nome = nome;
    _email = email;
    
    print('✅ [UserProvider] Dados definidos, notificando listeners...');
    notifyListeners();
    print('🔔 [UserProvider] Listeners notificados');
  }

  /// Limpa dados do usuário (logout)
  void clearUserData() {
    print('🗑️ [UserProvider] Limpando dados do usuário...');
    print('🆔 [UserProvider] ID anterior: $_id');
    print('📛 [UserProvider] Nome anterior: $_nome');
    print('📧 [UserProvider] Email anterior: $_email');
    
    _id = null;
    _nome = null;
    _email = null;
    
    print('✅ [UserProvider] Dados limpos, notificando listeners...');
    notifyListeners();
    print('🔔 [UserProvider] Listeners notificados');
  }

  @override
  void dispose() {
    print('🗑️ [UserProvider] dispose chamado');
    super.dispose();
  }
}

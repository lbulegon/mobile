import 'package:mobx/mobx.dart';

// Gera o código automaticamente
part 'login_store.g.dart';

class LoginStore = LoginStoreBase with _$LoginStore;

abstract class LoginStoreBase with Store {
  LoginStoreBase() {
    // Removido autorun desnecessário para economizar bateria
    // autorun((_) {
    //   print(email);
    // });
  }

  @observable
  String email = "";

  @action
  void setEmail(String value) =>
      email = value; //seta um nova valor para dentro do email atraves do action

  @observable
  String password = "";

  @action
  void setPassword(String value) =>
      password = value; //seta um novo valor para o apssword apartir do action
}

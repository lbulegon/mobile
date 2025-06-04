import 'dart:convert';
import 'package:flutter_application_4/models/random_user_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<RandomUser> getRandomUser() async {
  const url = "https://randomuser.me/api/";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return RandomUser.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Deu ruim");
  }
}

Future<bool> login(String email, String password) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  var url =
      Uri.parse('https://autentica-desenvolvimento.up.railway.app/api/login/');

  var resposta = await http.post(
    url,
    body: {
      'email': email,
      'password': password,
    },
  );

  if (resposta.statusCode == 200) {
    await sharedPreferences.setString(
        'token', "Token ${jsonDecode(resposta.body)['token']}");
    return true;
  } else {
    print(jsonDecode(resposta.body));
    return false;
  }
}

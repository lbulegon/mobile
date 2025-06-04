class Vagas {
  String empresa;
  String local;
  String dia;
  String hora;
  String valor;

  Vagas({
    required this.empresa,
    required this.local,
    required this.dia,
    required this.hora,
    required this.valor,
  });
}

class Pessoa {
  String nome;
  int idade;

  // Construtor
  Pessoa(this.nome, this.idade);

  // Método da classe
  void dizerOla() {
    // ignore: avoid_print
    print('Olá, meu nome é $nome e tenho $idade anos.');
  }
}

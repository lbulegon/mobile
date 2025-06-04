import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pacote para formatação de data

class VagasPage extends StatelessWidget {
  const VagasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vagas Disponíveis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Exemplo de lista de vagas
            VagaCard(
              titulo: 'Entregador para Restaurante',
              descricao:
                  'Horário: 18h às 22h\nLocal: Centro\nPagamento: R\$4,50 por entrega',
              data: DateTime.now(), // Data de hoje
            ),
            VagaCard(
              titulo: 'Motoboy para Farmácia',
              descricao:
                  'Horário: 9h às 15h\nLocal: Bairro Sul\nPagamento: R\$7,0 por entrega',
              data: DateTime.now()
                  .subtract(const Duration(days: 1)), // Data de ontem
            ),
            VagaCard(
              titulo: 'Frete para Loja de Eletrônicos',
              descricao:
                  'Horário: 10h às 18h\nLocal: Bairro Norte\nPagamento: R\$6,5 por entrega',
              data: DateTime.now()
                  .subtract(const Duration(days: 2)), // Data de anteontem
            ),
          ],
        ),
      ),
    );
  }
}

class VagaCard extends StatelessWidget {
  final String titulo;
  final String descricao;
  final DateTime data;

  const VagaCard({
    super.key,
    required this.titulo,
    required this.descricao,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    // Formatar a data
    String formattedDate =
        DateFormat('dd/MM/yyyy').format(data); // Exemplo simples de formatação

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              descricao,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Publicado em: $formattedDate', // Exibindo a data formatada
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Você se candidatou para: $titulo'),
                    ),
                  );
                },
                child: const Text('Candidatar-se'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vagas.dart';
import '../services/api_vagas.dart';

class MinhasVagasPage extends StatefulWidget {
  const MinhasVagasPage({super.key});

  @override
  State<MinhasVagasPage> createState() => _MinhasVagasPageState();
}

class _MinhasVagasPageState extends State<MinhasVagasPage> {
  late Future<List<Vaga>> futureVagas;

  @override
  void initState() {
    super.initState();
    futureVagas = fetchMinhasVagas();
  }

  Future<void> _refreshVagas() async {
    setState(() {
      futureVagas = fetchMinhasVagas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Vagas'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshVagas,
        child: FutureBuilder<List<Vaga>>(
          future: futureVagas,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final vagas = snapshot.data!;
              if (vagas.isEmpty) {
                return const Center(
                  child: Text('Você não está vinculado a nenhuma vaga.'),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: vagas.length,
                itemBuilder: (context, index) {
                  final vaga = vagas[index];
                  return VagaCardMinhas(
                    vaga: vaga,
                    onCancelar: () async {
                      try {
                        await cancelarCandidatura(vaga.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Cancelou candidatura na vaga ${vaga.empresa}'),
                          ),
                        );
                        _refreshVagas();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao cancelar: $e'),
                          ),
                        );
                      }
                    },
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Erro ao carregar: ${snapshot.error}'),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class VagaCardMinhas extends StatelessWidget {
  final Vaga vaga;
  final VoidCallback onCancelar;

  const VagaCardMinhas({
    super.key,
    required this.vaga,
    required this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('dd/MM/yyyy').format(DateTime.parse(vaga.dia));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vaga.empresa,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Local: ${vaga.local}    (${vaga.quantidadeDisponivel})    \nDia: $formattedDate\nHorário: ${vaga.hora}\nObservação: ${vaga.observacao}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: onCancelar,
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

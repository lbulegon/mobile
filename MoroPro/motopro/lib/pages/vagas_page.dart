// motopro/lib/pages/vagas_page.dart
import 'package:flutter/material.dart';
import '../models/vagas.dart';
import '../services/api_vagas.dart';
import '../services/local_storage.dart';

class VagasPage extends StatefulWidget {
  const VagasPage({super.key});

  @override
  State<VagasPage> createState() => _VagasPageState();
}

class _VagasPageState extends State<VagasPage> {
  List<Vaga> todasAsVagas = [];
  Set<int> vagasOcultadas = {};
  bool carregando = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregarVagas();
  }

  Future<void> carregarVagas() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final lista = await fetchVagas();
      setState(() {
        todasAsVagas = lista;
        carregando = false;
      });
    } catch (e) {
      setState(() {
        erro = e.toString();
        carregando = false;
      });
    }
  }

  void ocultarVaga(int id) {
    setState(() {
      vagasOcultadas.add(id);
    });
  }

  void restaurarTodas() {
    setState(() {
      vagasOcultadas.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vagasVisiveis = todasAsVagas
        .where((vaga) => !vagasOcultadas.contains(vaga.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vagas Disponíveis'),
        actions: [
          if (vagasOcultadas.isNotEmpty)
            TextButton(
              onPressed: restaurarTodas,
              child: const Text(
                'Mostrar todas',
                style: TextStyle(color: Colors.amber),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: carregarVagas,
        child: carregando
            ? const Center(child: CircularProgressIndicator())
            : erro != null
                ? Center(child: Text('Erro ao carregar vagas: $erro'))
                : vagasVisiveis.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('Nenhuma vaga disponível no momento.'),
                            SizedBox(height: 16),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: vagasVisiveis.length,
                        itemBuilder: (context, index) {
                          final vaga = vagasVisiveis[index];
                          return VagaCard(
                            vaga: vaga,
                            onCandidatar: () async {
                              try {
                                final motoboyId =
                                    await LocalStorage.getMotoboyId();
                                    
                                if (motoboyId == null) {
                                  Navigator.pushReplacementNamed(
                                      context, '/login');
                                  return;
                                }

                                await candidatarVaga(
                                  motoboyId: motoboyId ?? 0,
                                  estabelecimentoId: vaga.estabelecimentoId,
                                  data: vaga.dataISO,
                                  horaInicio: vaga.horaInicio,
                                  horaFim: vaga.horaFim,
                                );

                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Você se candidatou para ${vaga.empresa}',
                                    ),
                                  ),
                                );
                                carregarVagas();
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erro ao candidatar: $e'),
                                  ),
                                );
                              }
                            },
                            onOcultar: () => ocultarVaga(vaga.id),
                          );
                        },
                      ),
      ),
    );
  }
}

class VagaCard extends StatelessWidget {
  final Vaga vaga;
  final VoidCallback onCandidatar;
  final VoidCallback onOcultar;

  const VagaCard({
    super.key,
    required this.vaga,
    required this.onCandidatar,
    required this.onOcultar,
  });

  @override
  Widget build(BuildContext context) {
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
              'Local: ${vaga.local}\nDia: ${vaga.dia}\nHorário: ${vaga.hora}\nObservação: ${vaga.observacao}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onOcultar,
                  child: const Text('Ocultar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onCandidatar,
                  child: const Text('Candidatar-se'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

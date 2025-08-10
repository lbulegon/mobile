// motopro/lib/pages/vagas_page.dart
import 'package:flutter/material.dart';
import 'package:motopro/models/vagas.dart';
import 'package:motopro/services/api_vagas.dart' as vagas_api;
import 'package:motopro/services/local_storage.dart';

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
      final lista = await vagas_api.fetchVagas();
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

                                await vagas_api.candidatarVaga(
                                  motoboyId: motoboyId,
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
                                await carregarVagas();
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

class VagaCard extends StatefulWidget {
  final Vaga vaga;
  final Future<void> Function() onCandidatar;
  final VoidCallback onOcultar;

  const VagaCard({
    super.key,
    required this.vaga,
    required this.onCandidatar,
    required this.onOcultar,
  });

  @override
  State<VagaCard> createState() => _VagaCardState();
}

class _VagaCardState extends State<VagaCard> {
  bool _busy = false;

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
              widget.vaga.empresa,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Local: ${widget.vaga.local}\n'
              'Dia: ${widget.vaga.dia}\n'
              'Horário: ${widget.vaga.hora}\n'
              'Observação: ${widget.vaga.observacao}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _busy ? null : widget.onOcultar,
                  child: const Text('Ocultar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _busy
                      ? null
                      : () async {
                          setState(() => _busy = true);
                          try {
                            await widget.onCandidatar();
                          } finally {
                            if (mounted) setState(() => _busy = false);
                          }
                        },
                  child: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Candidatar-se'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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

  void _mostrarDetalhesVaga(BuildContext context, Vaga vaga) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            bool busy = false;
            
            Future<void> candidatarNoPopup() async {
              setState(() => busy = true);
              try {
                // Captura todos os valores da vaga
                final vagaId = vaga.id;
                final estabelecimentoId = vaga.estabelecimentoId;
                final dataISO = vaga.dataISO;
                final horaInicio = vaga.horaInicio;
                final horaFim = vaga.horaFim;
                final empresa = vaga.empresa;
                
                debugPrint('🔍 DEBUG - Candidatura via popup para vaga $vagaId ($empresa):');
                debugPrint('  vagaId: $vagaId');
                debugPrint('  estabelecimentoId: $estabelecimentoId');
                debugPrint('  dataISO: $dataISO');
                debugPrint('  horaInicio: $horaInicio');
                debugPrint('  horaFim: $horaFim');
                
                // Verificação de dados obrigatórios
                if (vagaId <= 0) {
                  throw Exception('ID da vaga inválido: $vagaId');
                }
                
                if (estabelecimentoId <= 0) {
                  throw Exception('ID do estabelecimento inválido: $estabelecimentoId');
                }
                
                if (dataISO.isEmpty) {
                  throw Exception('Data da vaga está vazia');
                }
                
                if (horaInicio.isEmpty || horaFim.isEmpty) {
                  throw Exception('Horários da vaga estão vazios');
                }
                
                final motoboyId = await LocalStorage.getMotoboyId();
                debugPrint('  motoboyId: $motoboyId');
                
                if (motoboyId <= 0) {
                  throw Exception('ID do motoboy inválido: $motoboyId');
                }

                // Tenta primeiro com método simplificado
                try {
                  await vagas_api.candidatarVagaSimples(vagaId);
                } catch (e) {
                  debugPrint('⚠️ Fallback para método completo: $e');
                  // Se falhou, tenta com método completo
                  await vagas_api.candidatarVaga(
                    motoboyId: motoboyId,
                    vagaId: vagaId,
                    estabelecimentoId: estabelecimentoId,
                    data: dataISO,
                    horaInicio: horaInicio,
                    horaFim: horaFim,
                  );
                }

                // Fecha o popup
                Navigator.of(context).pop();
                
                // Mostra mensagem de sucesso
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '✅ Vaga reservada com sucesso!',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text('🏢 $empresa'),
                        Text('📅 ${vaga.dia}'),
                        Text('🕐 ${vaga.hora}'),
                        SizedBox(height: 8),
                        Text(
                          '🎯 A vaga está disponível para você iniciar a operação quando chegar a data/hora marcada.',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    duration: Duration(seconds: 5),
                    backgroundColor: Colors.green.shade700,
                  ),
                );
                
                // Recarrega as vagas
                await carregarVagas();
                
              } catch (e) {
                debugPrint('❌ ERRO na candidatura via popup: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao candidatar: $e'),
                    backgroundColor: Colors.red.shade700,
                  ),
                );
              } finally {
                setState(() => busy = false);
              }
            }
            
            return AlertDialog(
              title: Text(
                'Detalhes da Vaga',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildInfoRow('🏢 Empresa', vaga.empresa),
                    _buildInfoRow('📍 Local', vaga.local),
                    _buildInfoRow('📅 Data', vaga.dia),
                    _buildInfoRow('🕐 Horário', vaga.hora),
                    _buildInfoRow('👥 Vagas Disponíveis', '${vaga.quantidadeDisponivel}'),
                    if (vaga.observacao.isNotEmpty)
                      _buildInfoRow('📝 Observações', vaga.observacao),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🎯 Como funciona',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• A vaga fica reservada para você automaticamente',
                            style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                          ),
                          Text(
                            '• No dia/hora marcada, você pode iniciar a operação',
                            style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                          ),
                          Text(
                            '• Confirme sua disponibilidade antes de reservar',
                            style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Fechar'),
                ),
                ElevatedButton(
                  onPressed: busy ? null : candidatarNoPopup,
                  child: busy
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Reservar Vaga'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
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
                          
                          // DEBUG: Log para verificar se há diferença no primeiro item
                          debugPrint('🔍 DEBUG - Item $index da lista:');
                          debugPrint('  vaga.id: ${vaga.id}');
                          debugPrint('  vaga.empresa: ${vaga.empresa}');
                          debugPrint('  vaga.dataISO: ${vaga.dataISO}');
                          debugPrint('  vaga.horaInicio: ${vaga.horaInicio}');
                          debugPrint('  vaga.horaFim: ${vaga.horaFim}');
                          debugPrint('  vaga.estabelecimentoId: ${vaga.estabelecimentoId}');
                          
                          return VagaCard(
                            vaga: vaga,
                            onOcultar: () => ocultarVaga(vaga.id),
                            onVerDetalhes: () => _mostrarDetalhesVaga(context, vaga),
                          );
                        },
                      ),
      ),
    );
  }
}

class VagaCard extends StatefulWidget {
  final Vaga vaga;
  final VoidCallback onOcultar;
  final VoidCallback onVerDetalhes;

  const VagaCard({
    super.key,
    required this.vaga,
    required this.onOcultar,
    required this.onVerDetalhes,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: _busy ? null : widget.onVerDetalhes,
                  icon: Icon(Icons.info_outline, size: 16),
                  label: Text('Ver Detalhes'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue.shade700,
                  ),
                ),
                OutlinedButton(
                  onPressed: _busy ? null : widget.onOcultar,
                  child: const Text('Ocultar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

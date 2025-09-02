import 'package:flutter/material.dart';
import 'package:motopro/services/minhas_candidaturas_service.dart';
import 'package:motopro/models/candidatura.dart';
import 'package:intl/intl.dart';

class MinhasCandidaturasPage extends StatefulWidget {
  const MinhasCandidaturasPage({super.key});

  @override
  State<MinhasCandidaturasPage> createState() => _MinhasCandidaturasPageState();
}

class _MinhasCandidaturasPageState extends State<MinhasCandidaturasPage> {
  List<Candidatura> _candidaturas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregarCandidaturas();
  }

  Future<void> _carregarCandidaturas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final candidaturas = await MinhasCandidaturasService.getMinhasCandidaturas();
      setState(() {
        _candidaturas = candidaturas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar candidaturas: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _iniciarAtividade(Candidatura candidatura) async {
    try {
      await MinhasCandidaturasService.iniciarAtividade(candidatura.id);
      
      // Recarrega a lista para atualizar o status
      await _carregarCandidaturas();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Atividade iniciada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao iniciar atividade: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _finalizarAtividade(Candidatura candidatura) async {
    try {
      await MinhasCandidaturasService.finalizarAtividade(candidatura.id);
      
      // Recarrega a lista para atualizar o status
      await _carregarCandidaturas();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Atividade finalizada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao finalizar atividade: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return '⏳ Pendente';
      case 'aprovada':
        return '✅ Aprovada';
      case 'rejeitada':
        return '❌ Rejeitada';
      case 'em_andamento':
        return '🔄 Em Andamento';
      case 'finalizada':
        return '🏁 Finalizada';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return Colors.orange;
      case 'aprovada':
        return Colors.green;
      case 'rejeitada':
        return Colors.red;
      case 'em_andamento':
        return Colors.blue;
      case 'finalizada':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildCandidaturaCard(Candidatura candidatura) {
    final dataFormatada = DateFormat('dd/MM/yyyy').format(candidatura.dataVaga);
    final horaFormatada = DateFormat('HH:mm').format(candidatura.horaInicio);
    final horaFimFormatada = DateFormat('HH:mm').format(candidatura.horaFim);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    candidatura.estabelecimento,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(candidatura.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(candidatura.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              candidatura.endereco,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Data: $dataFormatada',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Horário: $horaFormatada - $horaFimFormatada',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Valor: R\$ ${candidatura.valor.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Botões de ação baseados no status
            if (candidatura.status.toLowerCase() == 'aprovada')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _iniciarAtividade(candidatura),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar Atividade'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            
            if (candidatura.status.toLowerCase() == 'em_andamento')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _finalizarAtividade(candidatura),
                  icon: const Icon(Icons.stop),
                  label: const Text('Finalizar Atividade'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Candidaturas'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarCandidaturas,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _carregarCandidaturas,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : _candidaturas.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.work_outline, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma candidatura encontrada',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Candidate-se a vagas para ver suas atividades aqui',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _carregarCandidaturas,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: _candidaturas.length,
                        itemBuilder: (context, index) {
                          return _buildCandidaturaCard(_candidaturas[index]);
                        },
                      ),
                    ),
    );
  }
}


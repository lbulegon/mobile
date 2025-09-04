import 'package:flutter/material.dart';
import 'package:motopro/models/operacao.dart';
import 'package:motopro/services/operacao_service.dart';
import 'package:intl/intl.dart';

class OperacaoRelatoriosPage extends StatefulWidget {
  final Operacao operacao;
  
  const OperacaoRelatoriosPage({
    super.key,
    required this.operacao,
  });

  @override
  State<OperacaoRelatoriosPage> createState() => _OperacaoRelatoriosPageState();
}

class _OperacaoRelatoriosPageState extends State<OperacaoRelatoriosPage> {
  List<Relatorio> _relatorios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _relatorios = widget.operacao.relatorios;
    _isLoading = false;
  }

  Future<void> _atualizarRelatorios() async {
    setState(() => _isLoading = true);
    
    try {
      final relatorios = await OperacaoService.getRelatoriosOperacao(widget.operacao.id);
      setState(() {
        _relatorios = relatorios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao atualizar relatórios: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _adicionarRelatorio() async {
    final tipoController = TextEditingController();
    final descricaoController = TextEditingController();
    final observacoesController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Relatório'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tipoController,
                decoration: const InputDecoration(
                  labelText: 'Tipo do Relatório',
                  hintText: 'Ex: Problema, Observação, Sucesso',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Descreva o que aconteceu',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: observacoesController,
                decoration: const InputDecoration(
                  labelText: 'Observações (opcional)',
                  hintText: 'Informações adicionais',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (tipoController.text.isNotEmpty && descricaoController.text.isNotEmpty) {
                Navigator.pop(context, {
                  'tipo': tipoController.text,
                  'descricao': descricaoController.text,
                  'observacoes': observacoesController.text,
                });
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        await OperacaoService.adicionarRelatorio(
          widget.operacao.id,
          result['tipo']!,
          result['descricao']!,
          result['observacoes']!.isNotEmpty ? result['observacoes'] : null,
        );
        
        await _atualizarRelatorios();
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Relatório adicionado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao adicionar relatório: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getTipoText(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'problema':
        return '⚠️ Problema';
      case 'observacao':
        return '📝 Observação';
      case 'sucesso':
        return '✅ Sucesso';
      case 'atraso':
        return '⏰ Atraso';
      case 'cancelamento':
        return '❌ Cancelamento';
      default:
        return tipo;
    }
  }

  Color _getTipoColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'problema':
        return Colors.red;
      case 'observacao':
        return Colors.blue;
      case 'sucesso':
        return Colors.green;
      case 'atraso':
        return Colors.orange;
      case 'cancelamento':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRelatorioCard(Relatorio relatorio) {
    final dataHoraFormatada = DateFormat('dd/MM/yyyy HH:mm').format(relatorio.dataHora);

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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTipoColor(relatorio.tipo),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getTipoText(relatorio.tipo),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  dataHoraFormatada,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              relatorio.descricao,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (relatorio.observacoes != null && relatorio.observacoes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  relatorio.observacoes!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Botão para adicionar relatório
        Container(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _adicionarRelatorio,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Relatório'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
        
        // Lista de relatórios
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _relatorios.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assessment_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum relatório encontrado',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Adicione relatórios para registrar eventos da operação',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _atualizarRelatorios,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: _relatorios.length,
                        itemBuilder: (context, index) {
                          return _buildRelatorioCard(_relatorios[index]);
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}


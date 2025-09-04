import 'package:flutter/material.dart';
import 'package:motopro/models/operacao.dart';
import 'package:motopro/services/operacao_service.dart';
import 'package:motopro/pages/operacao_pedidos_page.dart';
import 'package:motopro/pages/operacao_relatorios_page.dart';
import 'package:intl/intl.dart';

class OperacaoPage extends StatefulWidget {
  final int operacaoId;
  
  const OperacaoPage({
    super.key,
    required this.operacaoId,
  });

  @override
  State<OperacaoPage> createState() => _OperacaoPageState();
}

class _OperacaoPageState extends State<OperacaoPage> {
  Operacao? _operacao;
  bool _isLoading = true;
  String? _error;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _carregarOperacao();
  }

  Future<void> _carregarOperacao() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final operacao = await OperacaoService.getOperacao(widget.operacaoId);
      setState(() {
        _operacao = operacao;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar operação: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _finalizarOperacao() async {
    if (_operacao == null) return;

    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Operação'),
        content: const Text(
          'Tem certeza que deseja finalizar esta operação? '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );

    if (confirmacao != true) return;

    try {
      await OperacaoService.finalizarOperacao(_operacao!.id);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Operação finalizada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context, true); // Retorna indicando que foi finalizada
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao finalizar operação: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildHeader() {
    if (_operacao == null) return const SizedBox.shrink();

    final dataFormatada = DateFormat('dd/MM/yyyy').format(_operacao!.dataVaga);
    final horaInicio = DateFormat('HH:mm').format(_operacao!.horaInicio);
    final horaFim = DateFormat('HH:mm').format(_operacao!.horaFim);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.work,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'OPERAÇÃO ATIVA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🔄 EM ANDAMENTO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _operacao!.estabelecimento,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _operacao!.endereco,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                'Data: $dataFormatada',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                'Horário: $horaInicio - $horaFim',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.attach_money, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                'Valor: R\$ ${_operacao!.valor.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    if (_operacao == null) return const SizedBox.shrink();

    final pedidosPendentes = _operacao!.pedidos.where((p) => p.status == 'pendente').length;
    final pedidosEmAndamento = _operacao!.pedidos.where((p) => p.status == 'em_andamento').length;
    final pedidosConcluidos = _operacao!.pedidos.where((p) => p.status == 'concluido').length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Pendentes',
              pedidosPendentes.toString(),
              Colors.orange,
              Icons.schedule,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Em Andamento',
              pedidosEmAndamento.toString(),
              Colors.blue,
              Icons.delivery_dining,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Concluídos',
              pedidosConcluidos.toString(),
              Colors.green,
              Icons.check_circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_operacao == null) return const SizedBox.shrink();

    final pages = [
      OperacaoPedidosPage(operacao: _operacao!),
      OperacaoRelatoriosPage(operacao: _operacao!),
    ];

    return Expanded(
      child: Column(
        children: [
          _buildStats(),
          Expanded(
            child: pages[_selectedIndex],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operação'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarOperacao,
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: _finalizarOperacao,
            tooltip: 'Finalizar Operação',
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
                        onPressed: _carregarOperacao,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildHeader(),
                    _buildContent(),
                  ],
                ),
      bottomNavigationBar: _operacao != null
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  label: 'Pedidos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assessment),
                  label: 'Relatórios',
                ),
              ],
            )
          : null,
    );
  }
}


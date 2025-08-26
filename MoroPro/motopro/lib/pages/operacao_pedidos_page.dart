import 'package:flutter/material.dart';
import 'package:motopro/models/operacao.dart';
import 'package:motopro/services/operacao_service.dart';
import 'package:intl/intl.dart';

class OperacaoPedidosPage extends StatefulWidget {
  final Operacao operacao;
  
  const OperacaoPedidosPage({
    super.key,
    required this.operacao,
  });

  @override
  State<OperacaoPedidosPage> createState() => _OperacaoPedidosPageState();
}

class _OperacaoPedidosPageState extends State<OperacaoPedidosPage> {
  List<Pedido> _pedidos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pedidos = widget.operacao.pedidos;
    _isLoading = false;
  }

  Future<void> _atualizarPedidos() async {
    setState(() => _isLoading = true);
    
    try {
      final pedidos = await OperacaoService.getPedidosOperacao(widget.operacao.id);
      setState(() {
        _pedidos = pedidos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao atualizar pedidos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _registrarColeta(Pedido pedido) async {
    try {
      await OperacaoService.registrarColeta(widget.operacao.id, pedido.id);
      await _atualizarPedidos();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Coleta registrada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao registrar coleta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _registrarEntrega(Pedido pedido) async {
    try {
      await OperacaoService.registrarEntrega(widget.operacao.id, pedido.id);
      await _atualizarPedidos();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Entrega registrada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao registrar entrega: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return '⏳ Pendente';
      case 'em_andamento':
        return '🔄 Em Andamento';
      case 'coletado':
        return '📦 Coletado';
      case 'entregue':
        return '✅ Entregue';
      case 'cancelado':
        return '❌ Cancelado';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return Colors.orange;
      case 'em_andamento':
        return Colors.blue;
      case 'coletado':
        return Colors.purple;
      case 'entregue':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPedidoCard(Pedido pedido) {
    final horaColeta = pedido.horaColeta != null 
        ? DateFormat('HH:mm').format(pedido.horaColeta!)
        : null;
    final horaEntrega = pedido.horaEntrega != null 
        ? DateFormat('HH:mm').format(pedido.horaEntrega!)
        : null;

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
                    pedido.cliente,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(pedido.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(pedido.status),
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
              pedido.enderecoEntrega,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pedido.descricao,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'R\$ ${pedido.valor.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (horaColeta != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Coletado às: $horaColeta',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
            if (horaEntrega != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Entregue às: $horaEntrega',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            
            // Botões de ação baseados no status
            if (pedido.status.toLowerCase() == 'pendente')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _registrarColeta(pedido),
                      icon: const Icon(Icons.shopping_bag),
                      label: const Text('Registrar Coleta'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            
            if (pedido.status.toLowerCase() == 'coletado')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _registrarEntrega(pedido),
                      icon: const Icon(Icons.delivery_dining),
                      label: const Text('Registrar Entrega'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pedidos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhum pedido encontrado',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Os pedidos aparecerão aqui quando estiverem disponíveis',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _atualizarPedidos,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: _pedidos.length,
        itemBuilder: (context, index) {
          return _buildPedidoCard(_pedidos[index]);
        },
      ),
    );
  }
}


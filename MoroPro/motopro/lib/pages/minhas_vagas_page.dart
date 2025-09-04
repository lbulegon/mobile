//motopro/lib/pages/minhas_vagas_page.dart
import 'package:flutter/material.dart';
import 'package:motopro/models/candidatura.dart';
import '../services/minhas_vagas_service.dart';
import 'package:motopro/pages/operacao_page.dart';
import 'package:intl/intl.dart';

class MinhasVagasPage extends StatefulWidget {
  const MinhasVagasPage({super.key});

  @override
  State<MinhasVagasPage> createState() => _MinhasVagasPageState();
}

class _MinhasVagasPageState extends State<MinhasVagasPage> {
  List<Candidatura> _vagas = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarVagas();
  }

  @override
  void dispose() {
    print('🗑️ [MinhasVagasPage] dispose chamado');
    super.dispose();
  }

  Future<void> _carregarVagas() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      debugPrint('[MinhasVagasPage] Iniciando carregamento das vagas...');
      final vagas = await MinhasVagasService.getMinhasVagas();
      
      debugPrint('[MinhasVagasPage] Vagas carregadas: ${vagas.length}');
      
      setState(() {
        _vagas = vagas;
        _carregando = false;
      });
    } catch (e) {
      debugPrint('[MinhasVagasPage] Erro ao carregar vagas: $e');
      setState(() {
        _erro = 'Erro ao carregar vagas: $e';
        _carregando = false;
      });
    }
  }

  Future<void> _iniciarOperacao(Candidatura candidatura) async {
    try {
      debugPrint('[MinhasVagasPage] Iniciando operação para alocação ${candidatura.alocacaoId}');
      
      final sucesso = await MinhasVagasService.iniciarOperacao(candidatura.alocacaoId);
      
      if (sucesso) {
        debugPrint('[MinhasVagasPage] Operação iniciada com sucesso');
        
        if (!mounted) return;
        
        // Navega para a página de operação
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OperacaoPage(operacaoId: candidatura.alocacaoId),
          ),
        );
      } else {
        debugPrint('[MinhasVagasPage] Falha ao iniciar operação');
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao iniciar operação. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('[MinhasVagasPage] Erro ao iniciar operação: $e');
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _continuarOperacao(Candidatura candidatura) async {
    try {
      debugPrint('[MinhasVagasPage] Continuando operação para vaga ${candidatura.id}');
      
      // Navega diretamente para a página de operação
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OperacaoPage(operacaoId: candidatura.id),
        ),
      );
    } catch (e) {
      debugPrint('[MinhasVagasPage] Erro ao continuar operação: $e');
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Vagas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarVagas,
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Erro: $_erro',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _carregarVagas,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : _vagas.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.work_off,
                              size: 80,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Nenhuma vaga ativa',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.titleLarge?.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Você não possui vagas reservadas para os próximos dias.\n\nPara começar a trabalhar, acesse a aba "Vagas" e candidate-se a uma vaga disponível.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Para ver vagas disponíveis, navegue para a aba "Vagas"',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).textTheme.bodyMedium?.color,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _carregarVagas,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _vagas.length,
                        itemBuilder: (context, index) {
                          final candidatura = _vagas[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            color: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header com estabelecimento
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.business,
                                        color: Colors.blue.shade700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          candidatura.estabelecimento,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  // Endereço
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          candidatura.endereco,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // Data e horário em linha
                                  Row(
                                    children: [
                                      // Data
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 16,
                                              color: Colors.green.shade700,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              DateFormat('dd/MM/yyyy').format(candidatura.dataVaga),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Horário
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              size: 16,
                                              color: Colors.orange.shade700,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '${DateFormat('HH:mm').format(candidatura.horaInicio)} - ${DateFormat('HH:mm').format(candidatura.horaFim)}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Botão de ação
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _iniciarOperacao(candidatura),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade600,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        elevation: 1,
                                      ),
                                      icon: const Icon(Icons.play_arrow, size: 18),
                                      label: const Text(
                                        'Iniciar Operação',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

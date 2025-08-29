//motopro/lib/pages/minhas_vagas_page.dart
import 'package:flutter/material.dart';
import 'package:motopro/models/candidatura.dart';
import 'package:motopro/services/minhas_vagas_service.dart';
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
      debugPrint('[MinhasVagasPage] Iniciando operação para vaga ${candidatura.id}');
      
      final sucesso = await MinhasVagasService.iniciarOperacao(candidatura.id);
      
      if (sucesso) {
        debugPrint('[MinhasVagasPage] Operação iniciada com sucesso');
        
        if (!mounted) return;
        
        // Navega para a página de operação
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OperacaoPage(operacaoId: candidatura.id),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.work_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nenhuma vaga futura encontrada',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Você não tem vagas reservadas a partir de hoje.\nReserve uma vaga na aba "Vagas" para começar.',
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Navega para a aba de Vagas
                              Navigator.pop(context);
                              // Mostra mensagem para o usuário
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Navegue para a aba "Vagas" para ver vagas disponíveis'),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            },
                            icon: const Icon(Icons.search),
                            label: const Text('Ver Vagas Disponíveis'),
                          ),
                        ],
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
                            color: Colors.white,
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
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
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
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
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
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
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


}

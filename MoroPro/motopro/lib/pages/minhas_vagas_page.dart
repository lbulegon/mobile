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
    print('💼 [MinhasVagasPage] initState chamado');
    _carregarVagas();
  }

  Future<void> _carregarVagas() async {
    print('🔄 [MinhasVagasPage] Iniciando carregamento das vagas...');
    setState(() {
      _carregando = true;
      _erro = null;
    });
    print('⏳ [MinhasVagasPage] Estado atualizado: carregando = true');

    try {
      debugPrint('[MinhasVagasPage] Iniciando carregamento das vagas...');
      print('📡 [MinhasVagasPage] Chamando MinhasVagasService.getMinhasVagas()...');
      final vagas = await MinhasVagasService.getMinhasVagas();
      
      print('✅ [MinhasVagasPage] Vagas carregadas com sucesso: ${vagas.length} vagas');
      debugPrint('[MinhasVagasPage] Vagas carregadas: ${vagas.length}');
      
      setState(() {
        _vagas = vagas;
        _carregando = false;
      });
      print('✅ [MinhasVagasPage] Estado atualizado: carregando = false, vagas = ${vagas.length}');
    } catch (e) {
      print('❌ [MinhasVagasPage] Erro ao carregar vagas: $e');
      debugPrint('[MinhasVagasPage] Erro ao carregar vagas: $e');
      setState(() {
        _erro = 'Erro ao carregar vagas: $e';
        _carregando = false;
      });
      print('⚠️ [MinhasVagasPage] Estado atualizado: carregando = false, erro = $_erro');
    }
  }

  Future<void> _iniciarOperacao(Candidatura candidatura) async {
    print('🚀 [MinhasVagasPage] Iniciando operação para candidatura: ${candidatura.id}');
    print('📋 [MinhasVagasPage] Detalhes: Estabelecimento: ${candidatura.estabelecimento}, Alocação: ${candidatura.alocacaoId}');
    
    try {
      debugPrint('[MinhasVagasPage] Iniciando operação para alocação ${candidatura.alocacaoId}');
      print('📡 [MinhasVagasPage] Chamando MinhasVagasService.iniciarOperacao(${candidatura.alocacaoId})...');
      
      final sucesso = await MinhasVagasService.iniciarOperacao(candidatura.alocacaoId);
      
      if (sucesso) {
        print('✅ [MinhasVagasPage] Operação iniciada com sucesso!');
        debugPrint('[MinhasVagasPage] Operação iniciada com sucesso');
        
        if (!mounted) {
          print('⚠️ [MinhasVagasPage] Widget não está montado após iniciar operação, abortando...');
          return;
        }
        
        // Navega para a página de operação
        print('🧭 [MinhasVagasPage] Navegando para OperacaoPage com ID: ${candidatura.alocacaoId}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OperacaoPage(operacaoId: candidatura.alocacaoId),
          ),
        );
        print('✅ [MinhasVagasPage] Navegação para OperacaoPage concluída');
      } else {
        print('❌ [MinhasVagasPage] Falha ao iniciar operação');
        debugPrint('[MinhasVagasPage] Falha ao iniciar operação');
        if (!mounted) {
          print('⚠️ [MinhasVagasPage] Widget não está montado após falha, abortando...');
          return;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao iniciar operação. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
        print('📱 [MinhasVagasPage] SnackBar de erro exibido');
      }
    } catch (e) {
      print('❌ [MinhasVagasPage] Erro ao iniciar operação: $e');
      debugPrint('[MinhasVagasPage] Erro ao iniciar operação: $e');
      if (!mounted) {
        print('⚠️ [MinhasVagasPage] Widget não está montado após erro, abortando...');
        return;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print('📱 [MinhasVagasPage] SnackBar de erro exibido');
    }
  }

  Future<void> _continuarOperacao(Candidatura candidatura) async {
    print('▶️ [MinhasVagasPage] Continuando operação para candidatura: ${candidatura.id}');
    try {
      debugPrint('[MinhasVagasPage] Continuando operação para vaga ${candidatura.id}');
      print('🧭 [MinhasVagasPage] Navegando diretamente para OperacaoPage com ID: ${candidatura.id}');
      
      // Navega diretamente para a página de operação
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OperacaoPage(operacaoId: candidatura.id),
        ),
      );
      print('✅ [MinhasVagasPage] Navegação para OperacaoPage concluída');
    } catch (e) {
      print('❌ [MinhasVagasPage] Erro ao continuar operação: $e');
      debugPrint('[MinhasVagasPage] Erro ao continuar operação: $e');
      if (!mounted) {
        print('⚠️ [MinhasVagasPage] Widget não está montado após erro, abortando...');
        return;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print('📱 [MinhasVagasPage] SnackBar de erro exibido');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 [MinhasVagasPage] Construindo interface...');
    print('📊 [MinhasVagasPage] Estado atual: carregando=$_carregando, erro=$_erro, vagas=${_vagas.length}');
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Minhas Vagas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              print('🔄 [MinhasVagasPage] Botão refresh pressionado');
              _carregarVagas();
            },
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: _carregando
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Carregando suas vagas...'),
                  ],
                ),
              )
            : _erro != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erro: $_erro',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            print('🔄 [MinhasVagasPage] Botão "Tentar Novamente" pressionado');
                            _carregarVagas();
                          },
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
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        print('🔍 [MinhasVagasPage] Botão "Ver Vagas" pressionado');
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Navegue para a aba "Vagas" para ver opções disponíveis'),
                                            duration: Duration(seconds: 3),
                                          ),
                                        );
                                        print('📱 [MinhasVagasPage] SnackBar de orientação exibido');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      icon: const Icon(Icons.search, size: 20),
                                      label: const Text(
                                        'Ver Vagas',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        print('🔄 [MinhasVagasPage] Botão "Atualizar" pressionado');
                                        _carregarVagas();
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Theme.of(context).colorScheme.primary,
                                        side: BorderSide(
                                          color: Theme.of(context).colorScheme.primary,
                                          width: 2,
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      icon: const Icon(Icons.refresh, size: 20),
                                      label: const Text(
                                        'Atualizar',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
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
                                        'Dica: As vagas aparecem aqui após você se candidatar e ser aprovado pelo estabelecimento.',
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
                        onRefresh: () {
                          print('🔄 [MinhasVagasPage] RefreshIndicator ativado (pull-to-refresh)');
                          return _carregarVagas();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _vagas.length,
                          itemBuilder: (context, index) {
                            final candidatura = _vagas[index];
                            print('🏗️ [MinhasVagasPage] Construindo card para candidatura ${index + 1}/${_vagas.length}: ${candidatura.estabelecimento}');
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 4,
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
                                          color: Theme.of(context).colorScheme.primary,
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
                                          color: Theme.of(context).colorScheme.secondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            candidatura.endereco,
                                            style: TextStyle(
                                              color: Theme.of(context).textTheme.bodyMedium?.color,
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
                                                color: Colors.green.shade600,
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
                                                color: Colors.orange.shade600,
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
                                        onPressed: () {
                                          print('🚀 [MinhasVagasPage] Botão "Iniciar Operação" pressionado para candidatura: ${candidatura.id}');
                                          _iniciarOperacao(candidatura);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).colorScheme.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          elevation: 2,
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
      ),
    );
  }

  @override
  void dispose() {
    print('🗑️ [MinhasVagasPage] dispose chamado');
    super.dispose();
  }
}

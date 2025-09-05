import 'package:flutter/material.dart';
import 'package:motopro/models/vagas.dart';
import 'package:motopro/services/api_vagas.dart';
import 'package:motopro/services/local_storage.dart';

class VagasPage extends StatefulWidget {
  const VagasPage({super.key});

  @override
  State<VagasPage> createState() => _VagasPageState();
}

class _VagasPageState extends State<VagasPage> {
  List<Vaga> _vagas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    print('🏗️ [VagasPage] initState chamado');
    _carregarVagas();
  }

  @override
  void dispose() {
    print('🗑️ [VagasPage] dispose chamado');
    super.dispose();
  }

  Future<void> _carregarVagas() async {
    print('🔄 [VagasPage] Iniciando carregamento de vagas...');
    setState(() {
      _isLoading = true;
      _error = null;
    });
    print('⏳ [VagasPage] Estado atualizado: carregando = true');

    try {
      print('📡 [VagasPage] Chamando ApiVagas.getVagasDisponiveis()...');
      final vagas = await ApiVagas.getVagasDisponiveis();

      print(
          '✅ [VagasPage] Vagas carregadas com sucesso: ${vagas.length} vagas');

      setState(() {
        _vagas = vagas;
        _isLoading = false;
      });
      print(
          '✅ [VagasPage] Estado atualizado: carregando = false, vagas = ${vagas.length}');
    } catch (e) {
      print('❌ [VagasPage] Erro ao carregar vagas: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print(
          '⚠️ [VagasPage] Estado atualizado: carregando = false, erro = $_error');
    }
  }

  Future<void> _candidatarVaga(Vaga vaga) async {
    print('🚀 [VagasPage] Iniciando candidatura para vaga: ${vaga.id}');
    print(
        '📋 [VagasPage] Detalhes da vaga: ${vaga.empresa} - ${vaga.dia} - ${vaga.hora}');

    try {
      // Obter o ID do motoboy logado
      final motoboyId = await LocalStorage.getMotoboyId();
      if (motoboyId == null) {
        throw Exception('Usuário não logado');
      }
      
      print(
          '📡 [VagasPage] Chamando ApiVagas.candidatarVaga($motoboyId, ${vaga.id})...');
      final success = await ApiVagas.candidatarVaga(motoboyId, vaga.id);

      print('✅ [VagasPage] Resposta da API: $success');

      if (!success) {
        print('❌ [VagasPage] API retornou false, lançando exceção...');
        throw Exception('Falha ao candidatar vaga');
      }

      print('🎉 [VagasPage] Candidatura bem-sucedida!');

      // Mostra mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vaga reservada com sucesso!'),
          backgroundColor: Colors.green.shade600,
          duration: Duration(seconds: 3),
        ),
      );

      print('🔄 [VagasPage] Recarregando vagas...');

      // Recarrega as vagas
      await _carregarVagas();

      print('✅ [VagasPage] Processo de candidatura concluído com sucesso!');
    } catch (e) {
      print('❌ [VagasPage] Erro durante candidatura: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao candidatar: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _mostrarDetalhesVaga(Vaga vaga) {
    print('🔍 [VagasPage] Mostrando detalhes da vaga: ${vaga.id}');
    print(
        '📋 [VagasPage] Detalhes: ${vaga.empresa} - ${vaga.dia} - ${vaga.hora}');

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          vaga.empresa,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoRow('🏢 Empresa', vaga.empresa),
                _buildInfoRow('📅 Data', vaga.dia),
                _buildInfoRow('🕐 Horário', vaga.hora),
                _buildInfoRow('📍 Local', vaga.local),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          print(
                              '❌ [VagasPage] Botão "Cancelar" pressionado, fechando popup...');
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          print(
                              '🚀 [VagasPage] Botão "Reservar" pressionado para vaga: ${vaga.id}');
                          Navigator.of(context).pop();
                          _candidatarVaga(vaga);
                        },
                        child: const Text('Reservar'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
    print('✅ [VagasPage] Popup de detalhes da vaga exibido');
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 [VagasPage] Construindo interface...');
    print(
        '📊 [VagasPage] Estado atual: carregando=$_isLoading, erro=$_error, vagas=${_vagas.length}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vagas Disponíveis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              print('🔄 [VagasPage] Botão refresh pressionado');
              _carregarVagas();
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    print('🏗️ [VagasPage] Construindo corpo da página...');

    try {
      if (_isLoading) {
        print('⏳ [VagasPage] Mostrando indicador de carregamento');
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Carregando vagas...'),
            ],
          ),
        );
      }

      if (_error != null) {
        print('❌ [VagasPage] Mostrando tela de erro: $_error');
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Erro ao carregar vagas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  print('🔄 [VagasPage] Botão "Tentar Novamente" pressionado');
                  _carregarVagas();
                },
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        );
      }

      if (_vagas.isEmpty) {
        print('📭 [VagasPage] Mostrando tela de vagas vazias');
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.work_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Nenhuma vaga disponível',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Não há vagas abertas no momento'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  print('🔄 [VagasPage] Botão "Atualizar" pressionado');
                  _carregarVagas();
                },
                child: const Text('Atualizar'),
              ),
            ],
          ),
        );
      }

      print('📋 [VagasPage] Mostrando lista de ${_vagas.length} vagas');
      return RefreshIndicator(
        onRefresh: () {
          print('🔄 [VagasPage] RefreshIndicator ativado (pull-to-refresh)');
          return _carregarVagas();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _vagas.length,
          itemBuilder: (context, index) {
            final vaga = _vagas[index];
            print(
                '🏗️ [VagasPage] Construindo card para vaga ${index + 1}/${_vagas.length}: ${vaga.empresa}');

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  vaga.empresa,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text('📅 ${vaga.dia}'),
                    Text('🕐 ${vaga.hora}'),
                    Text('📍 ${vaga.local}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    print(
                        '🔍 [VagasPage] Botão info pressionado para vaga: ${vaga.id}');
                    _mostrarDetalhesVaga(vaga);
                  },
                ),
                onTap: () {
                  print(
                      '👆 [VagasPage] Vaga ${vaga.id} tocada, mostrando detalhes...');
                  _mostrarDetalhesVaga(vaga);
                },
              ),
            );
          },
        ),
      );
    } catch (e) {
      print('💥 [VagasPage] Erro ao construir corpo da página: $e');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erro inesperado: $e'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                print('🔄 [VagasPage] Botão de recuperação pressionado');
                _carregarVagas();
              },
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }
  }
}

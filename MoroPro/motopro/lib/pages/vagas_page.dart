import 'package:flutter/material.dart';
import 'package:motopro/models/vagas.dart';
import 'package:motopro/services/api_vagas.dart';
import 'package:motopro/services/minhas_vagas_service.dart';

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
    _carregarVagas();
  }

  Future<void> _carregarVagas() async {
    print('🔍 DEBUG: _carregarVagas iniciado');
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🔍 DEBUG: Iniciando carregamento de vagas...');
      final vagas = await ApiVagas.getVagasDisponiveis();
      print('🔍 DEBUG: Vagas carregadas com sucesso: ${vagas.length}');
      
      if (!mounted) {
        print('🔍 DEBUG: Widget não está mais montado, abortando setState');
        return;
      }
      
      setState(() {
        print('🔍 DEBUG: Executando setState com ${vagas.length} vagas');
        _vagas = vagas;
        _isLoading = false;
      });
      
      print('🔍 DEBUG: setState concluído');
    } catch (e) {
      print('🔍 DEBUG: Erro na página de vagas: $e');
      
      if (!mounted) {
        print('🔍 DEBUG: Widget não está mais montado, abortando setState de erro');
        return;
      }
      
      setState(() {
        _error = 'Erro ao carregar vagas: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _candidatarVaga(Vaga vaga) async {
    try {
      final success = await ApiVagas.candidatarVaga(18, vaga.id);
      if (!success) {
        throw Exception('Falha ao candidatar vaga');
      }
      
      // Fecha o popup
      Navigator.of(context).pop();
      
      // Mostra mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Vaga Reservada com Sucesso!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text('🏢 ${vaga.empresa}', style: TextStyle(color: Colors.white)),
                Text('📅 ${vaga.dia}', style: TextStyle(color: Colors.white)),
                Text('🕐 ${vaga.hora}', style: TextStyle(color: Colors.white)),
                SizedBox(height: 8),
                Text(
                  'Toque para fechar',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          duration: Duration(days: 365), // Praticamente infinito
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16),
        ),
      );
      
      // Recarrega as vagas
      await _carregarVagas();
      
      // Mostra mensagem para navegar para Minhas Vagas
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vaga reservada! Toque na aba "Minhas Vagas" para ver suas reservas'),
          duration: Duration(seconds: 3),
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao candidatar: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _mostrarDetalhesVaga(Vaga vaga) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          vaga.empresa,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text('📍 ${vaga.local}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('📅 ${vaga.dia}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('🕐 ${vaga.hora}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('👥 ${vaga.quantidadeDisponivel} vagas disponíveis', style: TextStyle(fontSize: 16)),
                if (vaga.observacao.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text('📝 ${vaga.observacao}', style: TextStyle(fontSize: 16)),
                ],
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancelar'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _candidatarVaga(vaga);
                        },
                        child: Text('Reservar'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    try {
      if (_isLoading) {
        return Center(
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
        return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Erro ao carregar vagas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(_error!),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarVagas,
              child: Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

          if (_vagas.isEmpty) {
        return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhuma vaga disponível',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Não há vagas abertas no momento'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarVagas,
              child: Text('Atualizar'),
            ),
          ],
        ),
      );
    }

         return RefreshIndicator(
       onRefresh: _carregarVagas,
       child: ListView.builder(
         padding: EdgeInsets.all(16),
         itemCount: _vagas.length,
         itemBuilder: (context, index) {
           final vaga = _vagas[index];
                       return Card(
              margin: EdgeInsets.only(bottom: 16),
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
               padding: EdgeInsets.all(16),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   // Nome do estabelecimento
                                       Text(
                      vaga.empresa,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                   
                   SizedBox(height: 8),
                   
                   // Endereço
                   Row(
                     children: [
                       Icon(
                         Icons.location_on,
                         size: 16,
                         color: Colors.grey.shade600,
                       ),
                       SizedBox(width: 4),
                       Expanded(
                                                   child: Text(
                            vaga.local,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                       ),
                     ],
                   ),
                   
                   SizedBox(height: 12),
                   
                   // Data e horário
                   Row(
                     children: [
                       // Data
                       Expanded(
                         child: Row(
                           children: [
                             Icon(
                               Icons.calendar_today,
                               size: 16,
                               color: Colors.blue.shade600,
                             ),
                             SizedBox(width: 6),
                             Expanded(
                                                               child: Text(
                                  vaga.dia,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
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
                             SizedBox(width: 6),
                                                           Text(
                                vaga.hora,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                           ],
                         ),
                       ),
                     ],
                   ),
                   
                   SizedBox(height: 16),
                   
                   // Botão Ver Detalhes
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                       onPressed: () => _mostrarDetalhesVaga(vaga),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.blue.shade600,
                         foregroundColor: Colors.white,
                         padding: EdgeInsets.symmetric(vertical: 12),
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(8),
                         ),
                       ),
                       child: Text(
                         'Ver Detalhes',
                         style: TextStyle(
                           fontWeight: FontWeight.bold,
                           fontSize: 16,
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
      );
    } catch (e) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Vagas Disponíveis'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Erro ao carregar página',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Erro: $e',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _carregarVagas();
                },
                child: Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }
  }
}

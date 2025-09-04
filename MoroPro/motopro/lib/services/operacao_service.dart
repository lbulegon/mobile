import 'package:dio/dio.dart';
import 'package:motopro/services/network/dio_client.dart';
import 'package:motopro/models/operacao.dart';
import 'package:motopro/utils/app_config.dart';

class OperacaoService {
  /// Inicia uma operação (atividade) para uma candidatura
  static Future<Operacao> iniciarOperacao(int candidaturaId) async {
    try {
      final response = await DioClient.dio.post(
        '${AppConfig.apiUrl}/operacao/iniciar/',
        data: {
          'candidatura_id': candidaturaId,
        },
      );

      return Operacao.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Erro ao iniciar operação: ${e.message}');
    }
  }

  /// Finaliza uma operação
  static Future<Operacao> finalizarOperacao(int operacaoId) async {
    try {
      final response = await DioClient.dio.post(
        '${AppConfig.apiUrl}/operacao/$operacaoId/finalizar/',
      );

      return Operacao.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Erro ao finalizar operação: ${e.message}');
    }
  }

  /// Busca uma operação específica
  static Future<Operacao> getOperacao(int operacaoId) async {
    try {
      final response = await DioClient.dio.get(
        '${AppConfig.apiUrl}/operacao/$operacaoId/',
      );

      return Operacao.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Erro ao buscar operação: ${e.message}');
    }
  }

  /// Lista todas as operações do motoboy
  static Future<List<Operacao>> getMinhasOperacoes() async {
    try {
      final response = await DioClient.dio.get(
        '${AppConfig.apiUrl}/operacao/minhas-operacoes/',
      );

      return (response.data as List)
          .map((json) => Operacao.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('Erro ao buscar operações: ${e.message}');
    }
  }

  /// Busca operação ativa (em andamento)
  static Future<Operacao?> getOperacaoAtiva() async {
    try {
      final response = await DioClient.dio.get(
        '${AppConfig.apiUrl}/operacao/ativa/',
      );

      if (response.data != null) {
        return Operacao.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // Nenhuma operação ativa
      }
      throw Exception('Erro ao buscar operação ativa: ${e.message}');
    }
  }

  /// Registra coleta de um pedido
  static Future<Pedido> registrarColeta(int operacaoId, int pedidoId) async {
    try {
      final response = await DioClient.dio.post(
        '${AppConfig.apiUrl}/operacao/$operacaoId/pedido/$pedidoId/coletar/',
      );

      return Pedido.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Erro ao registrar coleta: ${e.message}');
    }
  }

  /// Registra entrega de um pedido
  static Future<Pedido> registrarEntrega(int operacaoId, int pedidoId) async {
    try {
      final response = await DioClient.dio.post(
        '${AppConfig.apiUrl}/operacao/$operacaoId/pedido/$pedidoId/entregar/',
      );

      return Pedido.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Erro ao registrar entrega: ${e.message}');
    }
  }

  /// Adiciona um relatório à operação
  static Future<Relatorio> adicionarRelatorio(
    int operacaoId,
    String tipo,
    String descricao,
    String? observacoes,
  ) async {
    try {
      final response = await DioClient.dio.post(
        '${AppConfig.apiUrl}/operacao/$operacaoId/relatorio/',
        data: {
          'tipo': tipo,
          'descricao': descricao,
          'observacoes': observacoes,
        },
      );

      return Relatorio.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Erro ao adicionar relatório: ${e.message}');
    }
  }

  /// Atualiza status de um pedido
  static Future<Pedido> atualizarStatusPedido(
    int operacaoId,
    int pedidoId,
    String novoStatus,
  ) async {
    try {
      final response = await DioClient.dio.patch(
        '${AppConfig.apiUrl}/operacao/$operacaoId/pedido/$pedidoId/',
        data: {
          'status': novoStatus,
        },
      );

      return Pedido.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Erro ao atualizar status do pedido: ${e.message}');
    }
  }

  /// Busca pedidos de uma operação
  static Future<List<Pedido>> getPedidosOperacao(int operacaoId) async {
    try {
      final response = await DioClient.dio.get(
        '${AppConfig.apiUrl}/operacao/$operacaoId/pedidos/',
      );

      return (response.data as List)
          .map((json) => Pedido.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('Erro ao buscar pedidos: ${e.message}');
    }
  }

  /// Busca relatórios de uma operação
  static Future<List<Relatorio>> getRelatoriosOperacao(int operacaoId) async {
    try {
      final response = await DioClient.dio.get(
        '${AppConfig.apiUrl}/operacao/$operacaoId/relatorios/',
      );

      return (response.data as List)
          .map((json) => Relatorio.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('Erro ao buscar relatórios: ${e.message}');
    }
  }
}


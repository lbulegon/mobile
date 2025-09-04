import 'package:flutter_test/flutter_test.dart';
import 'package:motopro/models/candidatura.dart';

void main() {
  group('Candidatura', () {
    group('fromJson', () {
      test('deve criar Candidatura a partir de JSON válido', () {
        final json = {
          'vaga_id': 123,
          'alocacao_id': 456,
          'empresa': 'Mister X',
          'endereco': 'Rua Teste, 123',
          'data': '2025-09-03',
          'inicio': '18:00',
          'fim': '01:00',
          'valor_vaga': 50.0,
          'status': 'ativa',
        };

        final candidatura = Candidatura.fromJson(json);

        expect(candidatura.id, equals(123));
        expect(candidatura.alocacaoId, equals(456));
        expect(candidatura.estabelecimento, equals('Mister X'));
        expect(candidatura.endereco, equals('Rua Teste, 123'));
        expect(candidatura.valor, equals(50.0));
        expect(candidatura.status, equals('ativa'));
      });

      test('deve lidar com dados ausentes', () {
        final json = <String, dynamic>{};

        final candidatura = Candidatura.fromJson(json);

        expect(candidatura.id, equals(0));
        expect(candidatura.alocacaoId, equals(0));
        expect(candidatura.estabelecimento, equals(''));
        expect(candidatura.endereco, equals(''));
        expect(candidatura.valor, equals(0.0));
        expect(candidatura.status, equals(''));
      });

      test('deve parsear data no formato DD/MM/YYYY', () {
        final json = {
          'vaga_id': 1,
          'alocacao_id': 1,
          'empresa': 'Test',
          'endereco': 'Test',
          'data': '03/09/2025',
          'inicio': '18:00',
          'fim': '01:00',
          'valor_vaga': 0,
          'status': 'test',
        };

        final candidatura = Candidatura.fromJson(json);

        expect(candidatura.dataVaga.year, equals(2025));
        expect(candidatura.dataVaga.month, equals(9));
        expect(candidatura.dataVaga.day, equals(3));
      });

      test('deve parsear data no formato ISO', () {
        final json = {
          'vaga_id': 1,
          'alocacao_id': 1,
          'empresa': 'Test',
          'endereco': 'Test',
          'data': '2025-09-03',
          'inicio': '18:00',
          'fim': '01:00',
          'valor_vaga': 0,
          'status': 'test',
        };

        final candidatura = Candidatura.fromJson(json);

        expect(candidatura.dataVaga.year, equals(2025));
        expect(candidatura.dataVaga.month, equals(9));
        expect(candidatura.dataVaga.day, equals(3));
      });

      test('deve parsear hora corretamente', () {
        final json = {
          'vaga_id': 1,
          'alocacao_id': 1,
          'empresa': 'Test',
          'endereco': 'Test',
          'data': '2025-09-03',
          'inicio': '18:30',
          'fim': '01:15',
          'valor_vaga': 0,
          'status': 'test',
        };

        final candidatura = Candidatura.fromJson(json);

        expect(candidatura.horaInicio.hour, equals(18));
        expect(candidatura.horaInicio.minute, equals(30));
        expect(candidatura.horaFim.hour, equals(1));
        expect(candidatura.horaFim.minute, equals(15));
      });

      test('deve lidar com valores numéricos como string', () {
        final json = {
          'vaga_id': '123',
          'alocacao_id': '456',
          'empresa': 'Test',
          'endereco': 'Test',
          'data': '2025-09-03',
          'inicio': '18:00',
          'fim': '01:00',
          'valor_vaga': '50.5',
          'status': 'test',
        };

        final candidatura = Candidatura.fromJson(json);

        expect(candidatura.id, equals(123));
        expect(candidatura.alocacaoId, equals(456));
        expect(candidatura.valor, equals(50.5));
      });
    });

    group('toJson', () {
      test('deve converter para JSON corretamente', () {
        final candidatura = Candidatura(
          id: 123,
          alocacaoId: 456,
          estabelecimento: 'Mister X',
          endereco: 'Rua Teste, 123',
          dataVaga: DateTime(2025, 9, 3),
          horaInicio: DateTime(2025, 9, 3, 18, 0),
          horaFim: DateTime(2025, 9, 3, 1, 0),
          valor: 50.0,
          status: 'ativa',
          dataCandidatura: DateTime(2025, 9, 1),
        );

        final json = candidatura.toJson();

        expect(json['id'], equals(123));
        expect(json['estabelecimento'], equals('Mister X'));
        expect(json['endereco'], equals('Rua Teste, 123'));
        expect(json['valor'], equals(50.0));
        expect(json['status'], equals('ativa'));
      });
    });
  });
}


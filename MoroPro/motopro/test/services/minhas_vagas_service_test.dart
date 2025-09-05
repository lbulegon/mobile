import 'package:flutter_test/flutter_test.dart';
import 'package:motopro/services/minhas_vagas_service.dart';
import 'package:motopro/models/candidatura.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('MinhasVagasService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    group('getMinhasVagas', () {
      test('deve retornar lista vazia quando não há token', () async {
        final vagas = await MinhasVagasService.getMinhasVagas();
        expect(vagas, isEmpty);
      });

      test('deve retornar lista vazia quando não há dados', () async {
        // Simula token válido mas sem dados
        await SharedPreferences.getInstance().then((prefs) {
          prefs.setString('access_token', 'valid.token');
        });
        
        final vagas = await MinhasVagasService.getMinhasVagas();
        expect(vagas, isEmpty);
      });
    });

    group('iniciarOperacao', () {
      test('deve retornar false quando não há token', () async {
        final sucesso = await MinhasVagasService.iniciarOperacao(123);
        expect(sucesso, isFalse);
      });

      test('deve retornar false para alocação inválida', () async {
        // Simula token válido
        await SharedPreferences.getInstance().then((prefs) {
          prefs.setString('access_token', 'valid.token');
        });
        
        final sucesso = await MinhasVagasService.iniciarOperacao(0);
        expect(sucesso, isFalse);
      });
    });

    group('getOperacaoAtiva', () {
      test('deve retornar null quando não há token', () async {
        final operacao = await MinhasVagasService.getOperacaoAtiva();
        expect(operacao, isNull);
      });

      test('deve retornar null quando não há dados', () async {
        // Simula token válido mas sem dados
        await SharedPreferences.getInstance().then((prefs) {
          prefs.setString('access_token', 'valid.token');
        });
        
        final operacao = await MinhasVagasService.getOperacaoAtiva();
        expect(operacao, isNull);
      });
    });
  });
}

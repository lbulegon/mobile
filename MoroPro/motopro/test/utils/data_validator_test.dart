import 'package:flutter_test/flutter_test.dart';
import 'package:motopro/utils/data_validator.dart';

void main() {
  group('DataValidator', () {
    group('isValidDate', () {
      test('deve retornar true para datas válidas', () {
        expect(DataValidator.isValidDate(DateTime(2025, 1, 1)), isTrue);
        expect(DataValidator.isValidDate(DateTime(2025, 12, 31)), isTrue);
        expect(DataValidator.isValidDate(DateTime(2000, 6, 15)), isTrue);
      });

      test('deve retornar false para datas inválidas', () {
        expect(DataValidator.isValidDate(DateTime(1899, 1, 1)), isFalse);
        expect(DataValidator.isValidDate(DateTime(2101, 1, 1)), isFalse);
        // Nota: DateTime(2025, 2, 30) e DateTime(2025, 4, 31) são automaticamente 
        // corrigidos pelo Dart para 2 de março e 1 de maio respectivamente
      });
    });

    group('isFutureDate', () {
      test('deve retornar true para datas futuras', () {
        final futureDate = DateTime.now().add(const Duration(days: 1));
        expect(DataValidator.isFutureDate(futureDate), isTrue);
      });

      test('deve retornar true para hoje', () {
        final today = DateTime.now();
        expect(DataValidator.isFutureDate(today), isTrue);
      });

      test('deve retornar false para datas passadas', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 1));
        expect(DataValidator.isFutureDate(pastDate), isFalse);
      });
    });

    group('isValidTime', () {
      test('deve retornar true para horas válidas', () {
        expect(DataValidator.isValidTime(0, 0), isTrue);
        expect(DataValidator.isValidTime(23, 59), isTrue);
        expect(DataValidator.isValidTime(12, 30), isTrue);
      });

      test('deve retornar false para horas inválidas', () {
        expect(DataValidator.isValidTime(-1, 0), isFalse);
        expect(DataValidator.isValidTime(24, 0), isFalse);
        expect(DataValidator.isValidTime(12, -1), isFalse);
        expect(DataValidator.isValidTime(12, 60), isFalse);
      });
    });

    group('isValidEmail', () {
      test('deve retornar true para emails válidos', () {
        expect(DataValidator.isValidEmail('test@example.com'), isTrue);
        expect(DataValidator.isValidEmail('user.name@domain.co.uk'), isTrue);
        expect(DataValidator.isValidEmail('test123@test.org'), isTrue);
      });

      test('deve retornar false para emails inválidos', () {
        expect(DataValidator.isValidEmail(''), isFalse);
        expect(DataValidator.isValidEmail('invalid-email'), isFalse);
        expect(DataValidator.isValidEmail('test@'), isFalse);
        expect(DataValidator.isValidEmail('@domain.com'), isFalse);
        expect(DataValidator.isValidEmail('test@domain'), isFalse);
      });
    });

    group('isValidPassword', () {
      test('deve retornar true para senhas válidas', () {
        expect(DataValidator.isValidPassword('Password123!'), isTrue);
        expect(DataValidator.isValidPassword('MySecure@Pass1'), isTrue);
      });

      test('deve retornar false para senhas inválidas', () {
        expect(DataValidator.isValidPassword(''), isFalse);
        expect(DataValidator.isValidPassword('1234567'), isFalse); // Muito curta
        expect(DataValidator.isValidPassword('password123'), isFalse); // Sem maiúscula
        expect(DataValidator.isValidPassword('PASSWORD123'), isFalse); // Sem minúscula
        expect(DataValidator.isValidPassword('Password'), isFalse); // Sem número
        expect(DataValidator.isValidPassword('Password123'), isFalse); // Sem caractere especial
      });
    });

    group('createSafeDate', () {
      test('deve criar datas válidas', () {
        final date = DataValidator.createSafeDate(2025, 1, 1);
        expect(date, isNotNull);
        expect(date!.year, equals(2025));
        expect(date.month, equals(1));
        expect(date.day, equals(1));
      });

      test('deve retornar null para datas inválidas', () {
        // Testa com ano fora do range válido
        expect(DataValidator.createSafeDate(1899, 1, 1), isNull);
        expect(DataValidator.createSafeDate(2101, 1, 1), isNull);
      });
    });

    group('shouldShowVaga', () {
      test('deve mostrar vaga futura', () {
        final dataVaga = DateTime.now().add(const Duration(days: 1));
        final horaInicio = DateTime(2025, 1, 1, 18, 0);
        final horaFim = DateTime(2025, 1, 1, 22, 0);
        
        expect(DataValidator.shouldShowVaga(dataVaga, horaInicio, horaFim), isTrue);
      });

      test('deve mostrar vaga de hoje que ainda não terminou', () {
        final agora = DateTime.now();
        final dataVaga = DateTime(agora.year, agora.month, agora.day);
        final horaInicio = DateTime(agora.year, agora.month, agora.day, 18, 0);
        final horaFim = DateTime(agora.year, agora.month, agora.day, agora.hour + 2, agora.minute);
        
        expect(DataValidator.shouldShowVaga(dataVaga, horaInicio, horaFim), isTrue);
      });

      test('não deve mostrar vaga de hoje que já terminou', () {
        final agora = DateTime.now();
        final dataVaga = DateTime(agora.year, agora.month, agora.day);
        final horaInicio = DateTime(agora.year, agora.month, agora.day, 18, 0);
        final horaFim = DateTime(agora.year, agora.month, agora.day, agora.hour - 2, agora.minute);
        
        expect(DataValidator.shouldShowVaga(dataVaga, horaInicio, horaFim), isFalse);
      });

      test('deve mostrar vaga que vai até madrugada do dia seguinte', () {
        final agora = DateTime.now();
        final dataVaga = DateTime(agora.year, agora.month, agora.day);
        final horaInicio = DateTime(agora.year, agora.month, agora.day, 22, 0);
        final horaFim = DateTime(agora.year, agora.month, agora.day, 2, 0); // 2:00 da madrugada
        
        expect(DataValidator.shouldShowVaga(dataVaga, horaInicio, horaFim), isTrue);
      });

      test('não deve mostrar vaga passada', () {
        final dataVaga = DateTime.now().subtract(const Duration(days: 1));
        final horaInicio = DateTime(2025, 1, 1, 18, 0);
        final horaFim = DateTime(2025, 1, 1, 22, 0);
        
        expect(DataValidator.shouldShowVaga(dataVaga, horaInicio, horaFim), isFalse);
      });

      test('não deve mostrar vaga de ontem que já terminou na madrugada', () {
        final agora = DateTime.now();
        final ontem = DateTime(agora.year, agora.month, agora.day - 1);
        final horaInicio = DateTime(ontem.year, ontem.month, ontem.day, 22, 0);
        final horaFim = DateTime(ontem.year, ontem.month, ontem.day, 2, 0);
        
        // Se agora for depois das 2:00, a vaga já terminou
        if (agora.hour > 2) {
          expect(DataValidator.shouldShowVaga(ontem, horaInicio, horaFim), isFalse);
        }
      });
    });
  });
}


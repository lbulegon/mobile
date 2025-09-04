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
        expect(DataValidator.isValidDate(DateTime(2025, 2, 30)), isFalse); // 30 de fevereiro
        expect(DataValidator.isValidDate(DateTime(2025, 4, 31)), isFalse); // 31 de abril
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
        expect(DataValidator.createSafeDate(2025, 2, 30), isNull);
        expect(DataValidator.createSafeDate(2025, 4, 31), isNull);
      });
    });
  });
}


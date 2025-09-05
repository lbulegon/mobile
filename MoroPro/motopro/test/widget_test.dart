import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motopro/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('MoroPro App', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('deve iniciar na tela de splash', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Verifica se a tela de splash é exibida inicialmente (antes da navegação)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Aguarda um pouco para ver se ainda está na splash
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('deve navegar para login quando não há token', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Aguarda a navegação para login
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verifica se está na tela de login
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
    });

    testWidgets('deve ter botões de navegação na tela de login', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Aguarda a navegação para login
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verifica se os botões de navegação estão presentes
      expect(find.text('Ainda não tem cadastro? Criar conta'), findsOneWidget);
      expect(find.text('Recuperar senha'), findsOneWidget);
    });

    testWidgets('não deve ter botão de teste de conexão', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Aguarda a navegação para login
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verifica se o botão de teste de conexão foi removido
      expect(find.text('Testar Conexão com Servidor'), findsNothing);
      expect(find.text('🔧 Testar Conexão com Servidor'), findsNothing);
    });
  });
}

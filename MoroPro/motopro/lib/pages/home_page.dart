import 'package:flutter/material.dart';
//import 'package:motopro/pages/boasvindas_page.dart';
import 'package:motopro/pages/vagas_page.dart';
import 'package:motopro/pages/minhas_vagas_page.dart';
import 'package:motopro/pages/perfil_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';
import 'package:motopro/providers/user_provider.dart';
import 'package:motopro/services/local_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const VagasPage(),
    const MinhasVagasPage(),
    const PerfilPage(),
  ];

  @override
  void initState() {
    super.initState();
    print('🏠 [HomePage] initState chamado, índice inicial: $_selectedIndex');
  }

  void _onItemTapped(int index) {
    print('👆 [HomePage] Aba selecionada: $index (${_getTabName(index)})');
    setState(() {
      _selectedIndex = index;
    });
    print('✅ [HomePage] Estado atualizado para aba: $_selectedIndex');
  }

  String _getTabName(int index) {
    switch (index) {
      case 0: return 'Home';
      case 1: return 'Vagas';
      case 2: return 'Minhas Vagas';
      case 3: return 'Perfil';
      default: return 'Desconhecida';
    }
  }

  Future<void> logout(BuildContext context) async {
    print('🚪 [HomePage] Iniciando processo de logout...');
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('🗑️ [HomePage] SharedPreferences limpo');
    
    await LocalStorage.clearTokens();
    print('🗑️ [HomePage] Tokens limpos do LocalStorage');
    
    if (!mounted) {
      print('⚠️ [HomePage] Widget não está montado durante logout, abortando...');
      return;
    }
    
    context.read<UserProvider>().clearUserData();
    print('🔄 [HomePage] UserProvider limpo');

    if (!mounted) {
      print('⚠️ [HomePage] Widget não está montado após limpar provider, abortando...');
      return;
    }
    
    print('🏠 [HomePage] Navegando para splash após logout...');
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (_) => false,
      arguments: {'logout': true},
    );
    print('✅ [HomePage] Logout concluído, navegação para splash');
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 [HomePage] Construindo interface, aba atual: $_selectedIndex (${_getTabName(_selectedIndex)})');
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('M o t o P r o'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Vagas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Minhas Vagas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  print('👤 [HomePage] Drawer construindo com usuário: ${userProvider.nome}');
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        userProvider.nome ?? 'MotoPro Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userProvider.email ?? '',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Vagas'),
              onTap: () {
                print('👆 [HomePage] Drawer: Vagas selecionado');
                _onItemTapped(1);
                Navigator.pop(context);
                print('✅ [HomePage] Drawer fechado e navegação para Vagas');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () async {
                print('👆 [HomePage] Drawer: Logout selecionado');
                Navigator.pop(context); // Fecha o drawer
                await logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('🗑️ [HomePage] dispose chamado');
    super.dispose();
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    print('🏠 [HomeContent] Construindo página inicial...');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: AssetImage('assets/banner.png'),
                fit: BoxFit.cover,
              ),
            ),
            
          ),
          const SizedBox(height: 24),
          Text(
            'Sugestões para Você',
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.star,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                'Participe de rotas mais curtas para ganhar experiência',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.local_offer,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                'Aproveite as promoções de horários especiais',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Dicas Profissionais',
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.lightbulb,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                'Mantenha sua moto revisada para evitar atrasos',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.security,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                'Use equipamentos de segurança sempre',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

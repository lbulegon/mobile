import 'package:flutter/material.dart';
import 'package:motopro/pages/boasvindas_page.dart';
import 'package:motopro/pages/vagas_page.dart';
import 'package:motopro/pages/perfil_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    const PerfilPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _sair() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const BoasVindasPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: const Text(
                'MotoPro Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Vagas'),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () async {
                Navigator.pop(context);
                await _sair();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📢 Banner de Propaganda
          // 📢 Banner de Propaganda
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent,
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image:
                    AssetImage('assets/banner.png'), // Substitua por seu asset
                fit: BoxFit.cover,
              ),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Porque quem acelera junto, entrega!',
              textAlign:
                  TextAlign.center, // 👈 Centraliza o texto dentro do box
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.black45,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 💡 Sugestões para você
          const Text(
            'Sugestões para Você',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.star),
              title: const Text(
                  'Participe de rotas mais curtas para ganhar experiência'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_offer),
              title: const Text('Aproveite as promoções de horários especiais'),
            ),
          ),
          const SizedBox(height: 24),

          // 🛠️ Dicas Profissionais
          const Text(
            'Dicas Profissionais',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lightbulb),
              title:
                  const Text('Mantenha sua moto revisada para evitar atrasos'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Use equipamentos de segurança sempre'),
            ),
          ),
        ],
      ),
    );
  }
}

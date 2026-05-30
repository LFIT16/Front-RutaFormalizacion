import 'package:flutter/material.dart';
import 'package:login_signup/components/tabs/home_tab.dart';
import 'package:login_signup/components/tabs/news_tab.dart';
import 'package:login_signup/components/tabs/chatbot_tab.dart';
import 'package:login_signup/components/tabs/laws_tab.dart';
import 'package:login_signup/components/tabs/profile_tab.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  void _navigateTo(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      HomeTab(onNavigate: _navigateTo),
      const NewsTab(),
      const ChatbotTab(),
      const LawsTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xff2E7D32),
        unselectedItemColor: const Color(0xff9E9E9E),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        backgroundColor: Colors.white,
        elevation: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.newspaper_outlined), activeIcon: Icon(Icons.newspaper), label: 'Noticias'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), activeIcon: Icon(Icons.smart_toy), label: 'IA Formalización'),
          BottomNavigationBarItem(icon: Icon(Icons.gavel_outlined), activeIcon: Icon(Icons.gavel), label: 'Normativas'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
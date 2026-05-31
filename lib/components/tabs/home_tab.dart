import 'package:flutter/material.dart';
import 'package:login_signup/services/token_service.dart';

class HomeTab extends StatefulWidget {
  final void Function(int) onNavigate;

  const HomeTab({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await TokenService.getUserName();
    setState(() => _userName = name ?? 'Emprendedor');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff2E7D32), Color(0xff66BB6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola, $_userName! 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Continúa tu proceso de formalización',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              '¿Qué quieres hacer hoy?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff333333)),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.1,
              children: [
                _buildCard(icon: Icons.newspaper, title: 'Noticias', subtitle: 'Últimas novedades', color: const Color(0xff1565C0), onTap: () => widget.onNavigate(1)),
                _buildCard(icon: Icons.smart_toy, title: 'IA Formalización', subtitle: 'Resuelve tus dudas', color: const Color(0xff6A1B9A), onTap: () => widget.onNavigate(2)),
                _buildCard(icon: Icons.gavel, title: 'Normativas', subtitle: 'Leyes vigentes', color: const Color(0xffE65100), onTap: () => widget.onNavigate(3)),
                _buildCard(icon: Icons.person, title: 'Mi Perfil', subtitle: 'Tu información', color: const Color(0xff2E7D32), onTap: () => widget.onNavigate(4)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff333333)), textAlign: TextAlign.center),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xff9E9E9E)), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
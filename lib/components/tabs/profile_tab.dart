import 'package:flutter/material.dart';
import 'package:login_signup/services/auth_service.dart';
import 'package:login_signup/services/token_service.dart';
import 'package:login_signup/components/edit_profile_page.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final result = await AuthService.getMe();
    setState(() {
      _user = result['success'] ? result['user'] : null;
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    await TokenService.clearUserData();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xff2E7D32)))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 50),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xff2E7D32), Color(0xff66BB6A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Text(
                      'Mi Perfil',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Avatar
                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xff2E7D32),
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10)
                            ],
                          ),
                          child: const Icon(Icons.person,
                              color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_user?['name'] ?? ''} ${_user?['lastName'] ?? ''}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff333333)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _user?['email'] ?? '',
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xff9E9E9E)),
                        ),
                        const SizedBox(height: 24),

                        // Datos
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              _buildInfoTile(
                                  icon: Icons.phone,
                                  label: 'Teléfono',
                                  value: _user?['phone'] ?? 'No registrado'),
                              _buildInfoTile(
                                  icon: Icons.location_on,
                                  label: 'Dirección',
                                  value: _user?['address'] ?? 'No registrada'),
                              const SizedBox(height: 20),

                              // Botón editar
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final updatedUser = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EditProfilePage(user: _user!),
                                      ),
                                    );
                                    // Si volvió con datos actualizados, refrescar el perfil
                                    if (updatedUser != null) {
                                      setState(() => _user = updatedUser);
                                    }
                                  },
                                  icon: const Icon(Icons.edit,
                                      color: Colors.white),
                                  label: const Text('Editar perfil',
                                      style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff2E7D32),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Botón cerrar sesión
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _handleLogout,
                                  icon: const Icon(Icons.logout,
                                      color: Colors.red),
                                  label: const Text('Cerrar sesión',
                                      style: TextStyle(color: Colors.red)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoTile(
      {required IconData icon, required String label, required String value}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff2E7D32), size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xff9E9E9E))),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xff333333),
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'profile/subscription_screen.dart';
import 'profile/change_password_screen.dart';
import 'profile/edit_profile_screen.dart';
import 'profile/registered_user_screen.dart';
import '../../../data/repositories/local_storage_service.dart';
import '../../../domain/entities/user.dart';
import '../../../data/service/notification_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final LocalStorageService _storageService = LocalStorageService();

  User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await _storageService.getCurrentUser();
      setState(() {
        currentUser = user;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar los datos del usuario'),
            backgroundColor: Color(0xFFE53E3E),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Perfil',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: () {
                _showLogoutDialog(context);
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header del perfil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // Nombre
                    Text(
                      '${currentUser?.firstName ?? ''} ${currentUser?.lastName ?? ''}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Email
                    Text(
                      '${currentUser?.email ?? ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Sección Ajustes
            _buildSectionHeader('Ajustes'),
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Perfil',
              onTap: () async {
                // Esperamos el resultado de la navegación
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );

                // Si el resultado es true, significa que hubo cambios
                if (result == true) {
                  await _loadData(); // Recargamos los datos del usuario
                }
              },
            ),
            _buildMenuItem(
              icon: Icons.lock_outline,
              title: 'Cambiar contraseña',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.payment_outlined,
              title: 'Subscripciones',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // Sección Ayuda
            _buildSectionHeader('Ayuda'),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'Sobre Nosotros',
              onTap: () {
                // Navegar a sobre nosotros
              },
            ),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Centro de ayuda',
              onTap: () {
                // Navegar a centro de ayuda
              },
            ),

            const SizedBox(height: 30),

            // Sección Información legal
            _buildSectionHeader('Información legal'),
            _buildMenuItem(
              icon: Icons.description_outlined,
              title: 'Términos y condiciones generales',
              onTap: () {
                // Navegar a términos y condiciones
              },
            ),
            _buildMenuItem(
              icon: Icons.table_chart_outlined,
              title: 'Registro de usuarios',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisteredUserScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacidad',
              onTap: () {
                // Navegar a privacidad
              },
            ),
            _buildMenuItem(
              icon: Icons.security_outlined,
              title: 'Política de privacidad',
              onTap: () {
                // Navegar a política de privacidad
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: Colors.black54,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Cerrar sesión',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          content: const Text(
            '¿Estás seguro de que quieres cerrar sesión?',
            style: TextStyle(color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async{
                Navigator.of(context).pop();
                await NotificationService.clearSession();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                      (route) => false,
                );
              },
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: Color(0xFFE53E3E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
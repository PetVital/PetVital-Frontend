// lib/ui/pages/main/widgets/bottom_navigation_widget.dart
import 'package:flutter/material.dart';

class BottomNavigationWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigationWidget({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.home,
            label: 'Inicio',
            isActive: currentIndex == 0,
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.calendar_today,
            label: 'Citas',
            isActive: currentIndex == 1,
          ),
          _buildNavItem(
            index: 2,
            icon: Icons.chat_bubble_outline,
            label: 'Chat',
            isActive: currentIndex == 2,
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.pets,
            label: 'Mascotas',
            isActive: currentIndex == 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Contenedor del ícono
            Container(
              width: isActive ? 43 : 37,
              height: isActive ? 43 : 37,
              decoration: isActive
                  ? BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8C52FF), Color(0xFF00A3FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              )
                  : null,
              child: Icon(
                icon,
                size: 26,
                color: isActive ? Colors.white : Colors.grey[600],
              ),
            ),
            isActive
                ? const SizedBox(height: 3)
                : const SizedBox(height: 0),
            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: isActive ? const Color(0xFF8C52FF) : Colors.grey[600],
                fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
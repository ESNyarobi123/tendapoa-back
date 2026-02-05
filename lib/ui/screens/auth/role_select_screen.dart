import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/constants.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const Text('Chagua Aina \nya Akaunti',
                  style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      height: 1.1)),
              const SizedBox(height: 15),
              const Text(
                  'Niambie namna ungependa kutumia Tendapoa ili tusaidie vizuri.',
                  style: TextStyle(
                      fontSize: 15, color: Color(0xFF64748B), height: 1.5)),
              const SizedBox(height: 50),
              _buildRoleCard(
                context,
                title: 'Natafuta Huduma',
                subtitle: 'Natafuta mafundi bomba, walimu, n.k.',
                icon: Icons.person_search_rounded,
                color: const Color(0xFF1E40AF),
                onTap: () => Navigator.pushNamed(context, '/register',
                    arguments: {'role': 'muhitaji'}),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 20),
              _buildRoleCard(
                context,
                title: 'Natoa Huduma',
                subtitle: 'Mimi ni fundi/mtaalamu natafuta kazi.',
                icon: Icons.construction_rounded,
                color: const Color(0xFFF97316),
                onTap: () => Navigator.pushNamed(context, '/register',
                    arguments: {'role': 'mfanyakazi'}),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                      children: [
                        TextSpan(text: 'Tayari una akaunti? '),
                        TextSpan(
                            text: 'Ingia hapa',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withValues(alpha: 0.1), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(20)),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B))),
                  const SizedBox(height: 5),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF64748B))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: color.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}

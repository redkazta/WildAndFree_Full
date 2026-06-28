import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class SidebarDrawer extends StatelessWidget {
  final String currentRoute;

  const SidebarDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.border),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.primary, width: 1),
                    ),
                    child: Image.asset(
                      'assets/wildgvng-logo.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Wild Gvng ERP',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return Text(
                        auth.profile?.email ?? '',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Navigation
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildNavItem(
                    context,
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    route: '/dashboard',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.shopping_bag_outlined,
                    label: 'Pedidos',
                    route: '/orders',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.inventory_2_outlined,
                    label: 'Inventario',
                    route: '/inventory',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.article_outlined,
                    label: 'Contenido',
                    route: '/content',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.people_outlined,
                    label: 'Usuarios',
                    route: '/users',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.label_outlined,
                    label: 'Tags',
                    route: '/tags',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.event_outlined,
                    label: 'Eventos',
                    route: '/events',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.sports_martial_arts_outlined,
                    label: 'Versus',
                    route: '/versus',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.settings_outlined,
                    label: 'Configuración',
                    route: '/settings',
                  ),
                ],
              ),
            ),

            // Footer actions
            const Divider(color: AppTheme.border),
            ListTile(
              leading: const Icon(Icons.open_in_new, color: AppTheme.textSecondary, size: 20),
              title: const Text(
                'Volver al sitio',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              onTap: () {
                Navigator.pop(context);
                // Could launch URL to web app
              },
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.error, size: 20),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: AppTheme.error, fontSize: 13),
              ),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthProvider>().signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    final isActive = currentRoute == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? AppTheme.primary : AppTheme.textSecondary,
        size: 20,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? AppTheme.primary : AppTheme.textSecondary,
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: isActive,
      selectedTileColor: AppTheme.primary.withAlpha(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      dense: true,
      onTap: () {
        Navigator.pop(context);
        if (!isActive) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
}

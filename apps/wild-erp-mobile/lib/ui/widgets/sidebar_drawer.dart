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
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.sideBarGradient,
          border: Border(
            right: BorderSide(color: AppTheme.borderGlow, width: 0.5),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with premium styling
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppTheme.borderGlow),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo + Title side by side - vertically aligned
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo container - same height as text
                        Container(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.borderGlow,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withAlpha(20),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/wg_logo.png',
                            width: 28,
                            height: 28,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Title block
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [AppTheme.primary, Colors.white70],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ).createShader(bounds),
                                child: const Text(
                                  'WILD GVNG',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              const Text(
                                'ERP',
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 10,
                                  letterSpacing: 3,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        final profile = auth.profile;
                        final hasAvatar = profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty;
                        final roleRaw = profile?.role ?? '';
                        String roleLabel;
                        switch (roleRaw.toLowerCase()) {
                          case 'admin':
                            roleLabel = 'ADMIN';
                            break;
                          case 'artist':
                            roleLabel = 'ARTIST';
                            break;
                          case 'fan':
                            roleLabel = 'FAN';
                            break;
                          default:
                            roleLabel = roleRaw.isEmpty ? 'USER' : roleRaw.toUpperCase();
                        }
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.border,
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Avatar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: hasAvatar
                                    ? Image.network(
                                        profile!.avatarUrl!,
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => _buildNoAvatar(),
                                      )
                                    : _buildNoAvatar(),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      profile?.displayName ?? profile?.email ?? '',
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      roleLabel,
                                      style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  children: [
                    _buildSectionLabel('MENÚ PRINCIPAL'),
                    const SizedBox(height: 4),
                    _buildNavItem(
                      context,
                      icon: Icons.dashboard_rounded,
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
                    const SizedBox(height: 8),
                    _buildSectionLabel('GESTIÓN'),
                    const SizedBox(height: 4),
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
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppTheme.borderGlow),
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.open_in_new,
                          color: AppTheme.textSecondary,
                          size: 16,
                        ),
                      ),
                      title: const Text(
                        'Volver al sitio',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // Could launch URL to web app
                      },
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: ListTile(
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.error.withAlpha(15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.logout,
                            color: AppTheme.error,
                            size: 16,
                          ),
                        ),
                        title: const Text(
                          'Cerrar sesión',
                          style: TextStyle(
                            color: AppTheme.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          context.read<AuthProvider>().signOut();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primary.withAlpha(60),
                AppTheme.primary.withAlpha(20),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.borderGlow,
              width: 0.5,
            ),
          ),
          child: const Icon(
            Icons.person,
            color: AppTheme.textSecondary,
            size: 18,
          ),
        ),
        Positioned(
          top: -2,
          right: -2,
          child: Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              color: AppTheme.accent,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '?',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 10,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: isActive
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withAlpha(20),
                  AppTheme.primary.withAlpha(5),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            )
          : null,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          splashColor: AppTheme.primary.withAlpha(10),
          highlightColor: AppTheme.primary.withAlpha(5),
          onTap: () {
            Navigator.pop(context);
            if (!isActive) {
              Navigator.pushReplacementNamed(context, route);
            }
          },
          child: Container(
            decoration: isActive
                ? const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: AppTheme.primary, width: 2.5),
                    ),
                  )
                : null,
            child: ListTile(
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
                  letterSpacing: 0.2,
                ),
              ),
              trailing: isActive
                  ? Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primary,
                      ),
                    )
                  : null,
              selected: isActive,
              selectedTileColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              dense: true,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
      ),
    );
  }
}

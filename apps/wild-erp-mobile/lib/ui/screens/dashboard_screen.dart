import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../providers/dashboard_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/sidebar_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarDrawer(currentRoute: '/dashboard'),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A0A0A), Color(0xFF0D0D0D), Color(0xFF0A0A0A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border(
              bottom: BorderSide(color: AppTheme.borderGlow, width: 0.5),
            ),
          ),
        ),
        title: const Text('Dashboard'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_outlined, size: 20),
              onPressed: () => context.read<DashboardProvider>().refresh(),
              tooltip: 'Refrescar',
            ),
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppTheme.primary,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            color: AppTheme.primary,
            backgroundColor: AppTheme.surface,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Welcome section with premium styling - compact
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primary.withAlpha(12),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.borderGlow,
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.dashboard_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Hola, ${auth.profile?.displayName ?? 'Admin'}',
                                          style: const TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          'Resumen general del sistema',
                                          style: TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.accent,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.accent.withAlpha(60),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 6),

                        // Stats Grid - compact 2x3
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.6,
                          children: [
                            _buildStatCard(
                              'Usuarios',
                              Formatters.formatCompact(provider.stats.totalUsers),
                              Icons.people_outline,
                              AppTheme.primary,
                              () => Navigator.pushNamed(context, '/users'),
                            ),
                            _buildStatCard(
                              'Artistas',
                              Formatters.formatCompact(provider.stats.totalArtists),
                              Icons.mic_none,
                              AppTheme.accent,
                              () => Navigator.pushNamed(context, '/users'),
                            ),
                            _buildStatCard(
                              'Pedidos Pendientes',
                              provider.stats.pendingOrders.toString(),
                              Icons.shopping_bag_outlined,
                              Colors.orange,
                              () => Navigator.pushNamed(context, '/orders'),
                            ),
                            _buildStatCard(
                              'Contenido Pendiente',
                              provider.stats.pendingContent.toString(),
                              Icons.article_outlined,
                              const Color(0xFF60A5FA),
                              () => Navigator.pushNamed(context, '/content'),
                            ),
                            _buildStatCard(
                              'Tokens Totales',
                              Formatters.formatToken(provider.stats.totalTokens),
                              Icons.token,
                              const Color(0xFFA78BFA),
                              () => Navigator.pushNamed(context, '/settings'),
                            ),
                            _buildStatCard(
                              'Eventos',
                              provider.stats.totalEvents.toString(),
                              Icons.event_outlined,
                              const Color(0xFF34D399),
                              () => Navigator.pushNamed(context, '/events'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Revenue card - compact
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0x18C98300), Color(0x08FFFFFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.borderGlow,
                              width: 0.5,
                            ),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.attach_money,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Ingresos Totales',
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        Formatters.formatNumber(provider.stats.totalRevenue),
                                        style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1,
                                        ),
                                        margin: const EdgeInsets.only(top: 1),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accent.withAlpha(25),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          '+12.5% vs mes anterior',
                                          style: TextStyle(
                                            color: AppTheme.accent,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.trending_up_rounded,
                                  color: AppTheme.accent,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Quick actions label + 3 buttons
                        Row(
                          children: [
                            const Icon(
                              Icons.flash_on_rounded,
                              color: AppTheme.primary,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Acciones Rápidas',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _buildQuickAction(
                              'Pedidos',
                              Icons.shopping_bag_outlined,
                              () => Navigator.pushNamed(context, '/orders'),
                            ),
                            const SizedBox(width: 6),
                            _buildQuickAction(
                              'Inventario',
                              Icons.inventory_2_outlined,
                              () => Navigator.pushNamed(context, '/inventory'),
                            ),
                            const SizedBox(width: 6),
                            _buildQuickAction(
                              'Usuarios',
                              Icons.people_outlined,
                              () => Navigator.pushNamed(context, '/users'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Total products card - compact row
                        Container(
                          decoration: AppTheme.cardDecoration,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withAlpha(20),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.inventory_2_outlined,
                                    color: AppTheme.primary,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Productos en inventario',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withAlpha(20),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    provider.stats.totalProducts.toString(),
                                    style: const TextStyle(
                                      color: AppTheme.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withAlpha(10),
            Colors.black.withAlpha(10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withAlpha(35),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: color.withAlpha(15),
          highlightColor: color.withAlpha(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 14),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          color: color,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 9,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.borderGlow,
            width: 0.5,
          ),
        ),
        child: Material(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            splashColor: AppTheme.primary.withAlpha(15),
            highlightColor: AppTheme.primary.withAlpha(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: AppTheme.primary, size: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

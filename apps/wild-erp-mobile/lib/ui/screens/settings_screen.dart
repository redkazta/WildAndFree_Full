import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/cache/cache_service.dart';
import '../../data/services/dashboard_service.dart';
import '../widgets/sidebar_drawer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  DashboardStats _stats = DashboardStats();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _stats = await DashboardService.getStats();
    } catch (e) {
      // Handle error
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarDrawer(currentRoute: '/settings'),
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // System info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Información del Sistema',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('App', 'Wild Gvng ERP Mobile'),
                        _buildInfoRow('Versión', '1.0.0+1'),
                        _buildInfoRow('Entorno', 'Producción'),
                        _buildInfoRow(
                            'Backend', 'Supabase'),
                        _buildInfoRow(
                            'Caché en memoria',
                            '${CacheService.size} items'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Token economy
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Economía de Tokens',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTokenStat(
                                'Total en circulación',
                                Formatters.formatToken(_stats.totalTokens),
                                AppTheme.accent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTokenStat(
                                'Ingresos totales',
                                Formatters.formatNumber(_stats.totalRevenue),
                                AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTokenStat(
                                'Usuarios',
                                _stats.totalUsers.toString(),
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTokenStat(
                                'Artistas',
                                _stats.totalArtists.toString(),
                                Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Quick stats
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resumen Rápido',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Pedidos pendientes',
                            _stats.pendingOrders.toString()),
                        _buildInfoRow('Contenido pendiente',
                            _stats.pendingContent.toString()),
                        _buildInfoRow('Productos en inventario',
                            _stats.totalProducts.toString()),
                        _buildInfoRow(
                            'Eventos totales', _stats.totalEvents.toString()),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Actions
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Acciones',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.refresh,
                              color: AppTheme.primary, size: 20),
                          title: const Text('Limpiar Caché',
                              style: TextStyle(color: AppTheme.textPrimary)),
                          subtitle: const Text(
                            'Forzar recarga de datos desde el servidor',
                            style: TextStyle(
                                color: AppTheme.textMuted, fontSize: 12),
                          ),
                          onTap: () {
                            CacheService.invalidateAll();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Caché limpiado'),
                                backgroundColor: AppTheme.accent,
                              ),
                            );
                          },
                        ),
                        const Divider(color: AppTheme.border),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.open_in_new,
                              color: AppTheme.primary, size: 20),
                          title: const Text('Abrir sitio web',
                              style: TextStyle(color: AppTheme.textPrimary)),
                          subtitle: const Text(
                            'Ir al sitio web de Wild Gvng',
                            style: TextStyle(
                                color: AppTheme.textMuted, fontSize: 12),
                          ),
                          onTap: () {
                            // Could launch URL
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Footer
                const Center(
                  child: Text(
                    '© 2025 Wild Gvng Music Hub',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

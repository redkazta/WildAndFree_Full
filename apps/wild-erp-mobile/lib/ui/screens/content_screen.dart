import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/status_badge.dart';
import '../providers/content_provider.dart';
import '../widgets/sidebar_drawer.dart';
import '../widgets/confirm_dialog.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().loadContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarDrawer(currentRoute: '/content'),
      appBar: AppBar(
        title: const Text('Contenido'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => context.read<ContentProvider>().loadContent(),
          ),
        ],
      ),
      body: Consumer<ContentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          final items = provider.items;

          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.article_outlined,
                      color: AppTheme.textMuted, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'No hay contenido',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Stats row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    _buildCountBadge(
                        'Pendiente', provider.pendingCount, Colors.orange),
                    const SizedBox(width: 8),
                    _buildCountBadge(
                        'Aprobado', provider.approvedCount, AppTheme.accent),
                    const SizedBox(width: 8),
                    _buildCountBadge(
                        'Rechazado', provider.rejectedCount, AppTheme.error),
                  ],
                ),
              ),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _buildFilterChip(provider, 'Todos', null),
                    const SizedBox(width: 8),
                    _buildFilterChip(provider, 'Pendiente', 'pending'),
                    const SizedBox(width: 8),
                    _buildFilterChip(provider, 'Aprobado', 'approved'),
                    const SizedBox(width: 8),
                    _buildFilterChip(provider, 'Rechazado', 'rejected'),
                  ],
                ),
              ),

              // Content list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.loadContent(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: AppTheme.cardDecoration,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withAlpha(20),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getContentIcon(item.type),
                                    color: AppTheme.primary,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${item.userName ?? "Desconocido"} · ${Formatters.timeAgo(item.createdAt)}',
                                        style: const TextStyle(
                                          color: AppTheme.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadge.fromStatus(item.status),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.favorite_outline,
                                    size: 14, color: AppTheme.textMuted),
                                const SizedBox(width: 4),
                                Text('${item.likes}',
                                    style: const TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 12)),
                                const SizedBox(width: 12),
                                Icon(Icons.visibility_outlined,
                                    size: 14, color: AppTheme.textMuted),
                                const SizedBox(width: 4),
                                Text('${item.views}',
                                    style: const TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 12)),
                                const Spacer(),
                                Text(item.type.toUpperCase(),
                                    style: const TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            if (item.isPending) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        final confirmed =
                                            await ConfirmDialog.show(
                                          context: context,
                                          title: 'Aprobar Contenido',
                                          message:
                                              '¿Aprobar "${item.title}"?',
                                          confirmLabel: 'Aprobar',
                                          confirmColor: AppTheme.accent,
                                        );
                                        if (confirmed && context.mounted) {
                                          await provider
                                              .approveContent(item.id);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content:
                                                    Text('Contenido aprobado'),
                                                backgroundColor:
                                                    AppTheme.accent,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.check,
                                          size: 16, color: AppTheme.accent),
                                      label: const Text('Aprobar',
                                          style: TextStyle(
                                              color: AppTheme.accent)),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                            color: AppTheme.accent
                                                .withAlpha(80)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        _showRejectDialog(
                                            context, provider, item.id);
                                      },
                                      icon: const Icon(Icons.close,
                                          size: 16, color: AppTheme.error),
                                      label: const Text('Rechazar',
                                          style: TextStyle(
                                              color: AppTheme.error)),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                            color: AppTheme.error
                                                .withAlpha(80)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCountBadge(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      ContentProvider provider, String label, String? status) {
    final isSelected = provider.statusFilter == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        provider.loadContent(status: status);
      },
      selectedColor: AppTheme.primary,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textSecondary,
        fontSize: 12,
      ),
    );
  }

  IconData _getContentIcon(String type) {
    switch (type) {
      case 'track':
        return Icons.music_note;
      case 'video':
        return Icons.videocam_outlined;
      case 'image':
        return Icons.image_outlined;
      case 'text':
        return Icons.article_outlined;
      default:
        return Icons.article_outlined;
    }
  }

  void _showRejectDialog(
      BuildContext context, ContentProvider provider, String itemId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.border),
        ),
        title: const Text('Rechazar Contenido',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Motivo del rechazo',
            hintText: 'Describe por qué se rechaza...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingresa un motivo'),
                    backgroundColor: AppTheme.error,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              await provider.rejectContent(
                  itemId, reasonController.text.trim());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contenido rechazado'),
                    backgroundColor: AppTheme.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }
}

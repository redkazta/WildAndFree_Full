import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/freestyler.dart';
import '../../data/services/versus_service.dart';
import '../widgets/sidebar_drawer.dart';
import '../widgets/confirm_dialog.dart';

class VersusScreen extends StatefulWidget {
  const VersusScreen({super.key});

  @override
  State<VersusScreen> createState() => _VersusScreenState();
}

class _VersusScreenState extends State<VersusScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Freestyler> _freestylers = [];
  List<Battle> _battles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        VersusService.getFreestylers(),
        VersusService.getBattles(),
      ]);
      _freestylers = results[0] as List<Freestyler>;
      _battles = results[1] as List<Battle>;
    } catch (e) {
      // Handle error
    }
    setState(() => _isLoading = false);
  }

  void _showAddFreestylerDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.border),
        ),
        title: const Text('Nuevo Freestyler',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              await VersusService.createFreestyler({
                'user_name': nameController.text.trim(),
                'elo_rating': 1000,
                'is_active': true,
              });
              if (context.mounted) {
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarDrawer(currentRoute: '/versus'),
      appBar: AppBar(
        title: const Text('Versus'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.appBarGradient,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Freestylers'),
            Tab(text: 'Batallas'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFreestylerDialog,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFreestylersTab(),
                _buildBattlesTab(),
              ],
            ),
    );
  }

  Widget _buildFreestylersTab() {
    if (_freestylers.isEmpty) {
      return const Center(
        child: Text(
          'No hay freestylers',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _freestylers.length,
        itemBuilder: (context, index) {
          final fs = _freestylers[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: AppTheme.cardDecoration,
            padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primary.withAlpha(30),
                        child: Text(
                          (fs.userName ?? '?').substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fs.userName ?? 'Desconocido',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'ELO: ${fs.eloRating} · ${fs.record}',
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${fs.winRate.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: fs.winRate >= 50
                              ? AppTheme.accent
                              : AppTheme.error,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Stat sliders
                  if (fs.statSliders != null)
                    ...fs.statSliders!.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: entry.value / 100,
                                backgroundColor: AppTheme.border,
                                color: AppTheme.primary,
                                minHeight: 4,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${entry.value.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatChip('W', fs.wins.toString(), AppTheme.accent),
                      const SizedBox(width: 6),
                      _buildStatChip(
                          'L', fs.losses.toString(), AppTheme.error),
                      const SizedBox(width: 6),
                      _buildStatChip(
                          'D', fs.draws.toString(), AppTheme.textMuted),
                      const SizedBox(width: 6),
                      _buildStatChip('Racha', fs.currentWinStreak.toString(),
                          Colors.orange),
                    ],
                  ),
                ],
              ),
          );
        },
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBattlesTab() {
    if (_battles.isEmpty) {
      return const Center(
        child: Text(
          'No hay batallas',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _battles.length,
        itemBuilder: (context, index) {
          final battle = _battles[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: AppTheme.cardDecoration,
            padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          battle.freestyler1Name ?? '???',
                          style: TextStyle(
                            color: battle.winnerId == battle.freestyler1Id
                                ? AppTheme.accent
                                : AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Text(
                        ' vs ',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 14,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          battle.freestyler2Name ?? '???',
                          style: TextStyle(
                            color: battle.winnerId == battle.freestyler2Id
                                ? AppTheme.accent
                                : AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (battle.score1 != null && battle.score2 != null)
                        Text(
                          '${battle.score1} - ${battle.score2}',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        battle.result,
                        style: TextStyle(
                          color: battle.isDraw
                              ? AppTheme.textMuted
                              : AppTheme.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        Formatters.formatDate(battle.battleDate),
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          );
        },
      ),
    );
  }
}

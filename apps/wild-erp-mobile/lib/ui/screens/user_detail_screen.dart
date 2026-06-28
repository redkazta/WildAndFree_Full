import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../providers/users_provider.dart';

class UserDetailScreen extends StatefulWidget {
  final String userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsersProvider>().loadUserDetail(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Usuario'),
      ),
      body: Consumer<UsersProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          final user = provider.selectedUser;
          if (user == null) {
            return const Center(
              child: Text('Usuario no encontrado',
                  style: TextStyle(color: AppTheme.textSecondary)),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            user.isArtist ? AppTheme.accent.withAlpha(30) : AppTheme.primary.withAlpha(30),
                        backgroundImage: user.avatarUrl != null
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                        child: user.avatarUrl == null
                            ? Text(
                                user.initials,
                                style: TextStyle(
                                  color: user.isArtist ? AppTheme.accent : AppTheme.primary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.displayName ?? 'Sin nombre',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBadge(
                              user.role.toUpperCase(), AppTheme.primary),
                          if (user.isArtist) ...[
                            const SizedBox(width: 8),
                            _buildBadge('ARTISTA', AppTheme.accent),
                          ],
                          if (user.isVerified) ...[
                            const SizedBox(width: 8),
                            _buildBadge('VERIFICADO', Colors.blue),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Stats
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildStatItem('Tokens', user.tokens.toString(), AppTheme.accent),
                      _buildStatItem('Pedidos', user.totalOrders.toString(), AppTheme.primary),
                      _buildStatItem(
                          'Gastado', '\$${user.totalSpent}', Colors.orange),
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
                      _buildActionTile(
                        icon: Icons.person_outline,
                        title: 'Verificar Artista',
                        subtitle: user.isArtist ? 'Artista verificado' : 'Marcar como artista',
                        trailing: Switch(
                          value: user.isArtist,
                          onChanged: (value) {
                            provider.toggleArtist(user.id, value);
                          },
                          activeColor: AppTheme.accent,
                        ),
                      ),
                      _buildActionTile(
                        icon: Icons.verified_outlined,
                        title: 'Verificación',
                        subtitle: user.isVerified ? 'Verificado' : 'Sin verificar',
                        trailing: Switch(
                          value: user.isVerified,
                          onChanged: (value) {
                            provider.toggleVerification(user.id, value);
                          },
                          activeColor: AppTheme.primary,
                        ),
                      ),
                      const Divider(color: AppTheme.border),
                      _buildActionTile(
                        icon: Icons.shield_outlined,
                        title: 'Rol',
                        subtitle: user.role.toUpperCase(),
                        trailing: DropdownButton<String>(
                          value: user.role,
                          dropdownColor: AppTheme.surfaceLight,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(
                                value: 'user', child: Text('User')),
                            DropdownMenuItem(
                                value: 'admin', child: Text('Admin')),
                            DropdownMenuItem(
                                value: 'moderator', child: Text('Moderator')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              provider.updateRole(user.id, value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Token assignment
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Asignar Tokens',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _TokenAssignForm(userId: user.id),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('ID', user.id),
                      _buildInfoRow(
                          'Registro', Formatters.formatDateTime(user.createdAt)),
                      _buildInfoRow(
                          'Actualización', Formatters.formatDateTime(user.updatedAt)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppTheme.textSecondary, size: 20),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 12,
        ),
      ),
      trailing: trailing,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _TokenAssignForm extends StatefulWidget {
  final String userId;

  const _TokenAssignForm({required this.userId});

  @override
  State<_TokenAssignForm> createState() => _TokenAssignFormState();
}

class _TokenAssignFormState extends State<_TokenAssignForm> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Cantidad',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () async {
            final tokens = int.tryParse(_controller.text) ?? 0;
            if (tokens > 0) {
              await context
                  .read<UsersProvider>()
                  .assignTokens(widget.userId, tokens);
              _controller.clear();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$tokens tokens asignados'),
                    backgroundColor: AppTheme.accent,
                  ),
                );
              }
            }
          },
          child: const Text('Asignar'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/status_badge.dart';
import '../providers/orders_provider.dart';
import '../widgets/confirm_dialog.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().loadOrderDetail(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Pedido'),
      ),
      body: Consumer<OrdersProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          final order = provider.selectedOrder;
          if (order == null) {
            return const Center(
              child: Text('Pedido no encontrado',
                  style: TextStyle(color: AppTheme.textSecondary)),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Order header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pedido #${order.id.substring(0, 8).toUpperCase()}',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          StatusBadge.fromStatus(order.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Cliente', order.userName ?? order.userId),
                      _buildInfoRow('Email', order.userEmail ?? 'N/A'),
                      _buildInfoRow(
                          'Fecha', Formatters.formatDateTime(order.createdAt)),
                      _buildInfoRow('Total', '${order.totalTokens} tokens'),
                      if (order.shippingAddress != null)
                        _buildInfoRow('Dirección', order.shippingAddress!),
                      if (order.notes != null)
                        _buildInfoRow('Notas', order.notes!),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Items
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Items',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (order.items.isEmpty)
                        const Text(
                          'Sin items',
                          style: TextStyle(color: AppTheme.textMuted),
                        )
                      else
                        ...order.items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productName ?? 'Producto',
                                          style: const TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (item.variantName != null)
                                          Text(
                                            item.variantName!,
                                            style: const TextStyle(
                                              color: AppTheme.textMuted,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'x${item.quantity}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '${item.subtotalTokens} tokens',
                                    style: const TextStyle(
                                      color: AppTheme.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Status update
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Actualizar Estado',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildStatusButton(
                            context,
                            order.id,
                            'pending',
                            'Pendiente',
                            Colors.orange,
                          ),
                          _buildStatusButton(
                            context,
                            order.id,
                            'processing',
                            'Procesando',
                            Colors.blue,
                          ),
                          _buildStatusButton(
                            context,
                            order.id,
                            'shipped',
                            'Enviado',
                            Colors.purple,
                          ),
                          _buildStatusButton(
                            context,
                            order.id,
                            'delivered',
                            'Entregado',
                            AppTheme.accent,
                          ),
                          _buildStatusButton(
                            context,
                            order.id,
                            'cancelled',
                            'Cancelado',
                            AppTheme.error,
                          ),
                        ],
                      ),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    String orderId,
    String status,
    String label,
    Color color,
  ) {
    return OutlinedButton(
      onPressed: () async {
        final confirmed = await ConfirmDialog.show(
          context: context,
          title: 'Cambiar Estado',
          message: '¿Cambiar estado a "$label"?',
          confirmLabel: 'Cambiar',
          confirmColor: color,
        );

        if (confirmed && context.mounted) {
          await context
              .read<OrdersProvider>()
              .updateStatus(orderId, status);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Estado cambiado a $label'),
                backgroundColor: AppTheme.accent,
              ),
            );
          }
        }
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withAlpha(80)),
        foregroundColor: color,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

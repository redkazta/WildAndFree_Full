import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../providers/inventory_provider.dart';
import '../widgets/confirm_dialog.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadProductDetail(widget.productId);
    });
  }

  void _showEditProductDialog() {
    final provider = context.read<InventoryProvider>();
    final product = provider.selectedProduct;
    if (product == null) return;

    final nameController = TextEditingController(text: product.name);
    final descController = TextEditingController(text: product.description ?? '');
    final priceController =
        TextEditingController(text: product.basePriceTokens.toString());
    final categoryController =
        TextEditingController(text: product.category);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.border),
        ),
        title: const Text('Editar Producto',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  validator: (v) => Validators.required(v, fieldName: 'Nombre'),
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceController,
                  validator: (v) => Validators.positiveNumber(v, fieldName: 'Precio'),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Precio (tokens)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                ),
              ],
            ),
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
              if (!formKey.currentState!.validate()) return;
              final success = await provider.updateProduct(product.id, {
                'name': nameController.text.trim(),
                'description': descController.text.trim(),
                'base_price_tokens': int.tryParse(priceController.text) ?? 0,
                'base_price_amount': int.tryParse(priceController.text) ?? 0,
                'category': categoryController.text.trim(),
              });
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Producto actualizado'),
                      backgroundColor: AppTheme.accent,
                    ),
                  );
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showAddVariantDialog() {
    final provider = context.read<InventoryProvider>();
    final product = provider.selectedProduct;
    if (product == null) return;

    final nameController = TextEditingController();
    final skuController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.border),
        ),
        title: const Text('Nueva Variante',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  validator: (v) => Validators.required(v, fieldName: 'Nombre'),
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: skuController,
                  decoration: const InputDecoration(labelText: 'SKU (opcional)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceController,
                  validator: (v) => Validators.number(v, fieldName: 'Precio'),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Precio (tokens)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: stockController,
                  validator: (v) => Validators.number(v, fieldName: 'Stock'),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Stock'),
                ),
              ],
            ),
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
              if (!formKey.currentState!.validate()) return;
              final success = await provider.createVariant({
                'product_id': product.id,
                'name': nameController.text.trim(),
                'sku': skuController.text.trim().isEmpty
                    ? null
                    : skuController.text.trim(),
                'price_tokens': int.tryParse(priceController.text) ?? 0,
                'price_amount': int.tryParse(priceController.text) ?? 0,
                'stock': int.tryParse(stockController.text) ?? 0,
                'is_active': true,
              });
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Variante creada'),
                      backgroundColor: AppTheme.accent,
                    ),
                  );
                }
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
      appBar: AppBar(
        title: const Text('Detalle del Producto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _showEditProductDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.error),
            onPressed: () async {
              final provider = context.read<InventoryProvider>();
              final product = provider.selectedProduct;
              if (product == null) return;

              final confirmed = await ConfirmDialog.show(
                context: context,
                title: 'Eliminar Producto',
                message:
                    '¿Estás seguro de eliminar "${product.name}"? Esta acción no se puede deshacer.',
                confirmLabel: 'Eliminar',
                confirmColor: AppTheme.error,
              );

              if (confirmed && context.mounted) {
                final success = await provider.deleteProduct(product.id);
                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Producto eliminado'),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddVariantDialog,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Variante'),
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          final product = provider.selectedProduct;
          if (product == null) {
            return const Center(
              child: Text('Producto no encontrado',
                  style: TextStyle(color: AppTheme.textSecondary)),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Product info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: product.isActive
                                  ? AppTheme.accent.withAlpha(30)
                                  : AppTheme.error.withAlpha(30),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.isActive ? 'ACTIVO' : 'INACTIVO',
                              style: TextStyle(
                                color: product.isActive
                                    ? AppTheme.accent
                                    : AppTheme.error,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (product.description != null &&
                          product.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          product.description!,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _buildInfoRow('Categoría', product.category),
                      _buildInfoRow(
                          'Precio base', '${product.basePriceTokens} tokens'),
                      _buildInfoRow(
                          'Total stock', product.totalStock.toString()),
                      _buildInfoRow(
                          'Variantes', product.variants.length.toString()),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Variants
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Variantes',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (product.variants.isEmpty)
                        const Text(
                          'Sin variantes. Agrega una variante para empezar.',
                          style: TextStyle(color: AppTheme.textMuted),
                        )
                      else
                        ...product.variants.map((variant) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Card(
                                color: AppTheme.background,
                                child: ListTile(
                                  title: Text(
                                    variant.displayName,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${variant.priceTokens} tokens · Stock: ${variant.stock}',
                                    style: TextStyle(
                                      color: variant.stock > 0
                                          ? AppTheme.accent
                                          : AppTheme.error,
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: PopupMenuButton(
                                    icon: const Icon(Icons.more_vert, size: 18),
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'stock',
                                        child: Text('Actualizar Stock'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Eliminar',
                                            style: TextStyle(
                                                color: AppTheme.error)),
                                      ),
                                    ],
                                    onSelected: (value) async {
                                      if (value == 'stock') {
                                        _showStockUpdateDialog(variant);
                                      } else if (value == 'delete') {
                                        final confirmed =
                                            await ConfirmDialog.show(
                                          context: context,
                                          title: 'Eliminar Variante',
                                          message:
                                              '¿Eliminar "${variant.name}"?',
                                          confirmLabel: 'Eliminar',
                                          confirmColor: AppTheme.error,
                                        );
                                        if (confirmed && context.mounted) {
                                          await provider.deleteVariant(
                                              variant.id, product.id);
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),
                            )),
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

  void _showStockUpdateDialog(dynamic variant) {
    final stockController =
        TextEditingController(text: variant.stock.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.border),
        ),
        title: const Text('Actualizar Stock',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: stockController,
            validator: (v) => Validators.number(v, fieldName: 'Stock'),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Nuevo stock'),
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
              if (!formKey.currentState!.validate()) return;
              final newStock = int.tryParse(stockController.text) ?? 0;
              await context
                  .read<InventoryProvider>()
                  .updateStock(variant.id, newStock);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
                color: AppTheme.textPrimary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

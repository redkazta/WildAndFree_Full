import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../data/models/tag.dart';
import '../../data/services/tags_service.dart';
import '../widgets/sidebar_drawer.dart';
import '../widgets/confirm_dialog.dart';

class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<TagCategory> _categories = [];
  List<Tag> _tags = [];
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
        TagsService.getCategories(),
        TagsService.getTags(),
      ]);
      _categories = results[0] as List<TagCategory>;
      _tags = results[1] as List<Tag>;
    } catch (e) {
      // Handle error
    }
    setState(() => _isLoading = false);
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.border),
        ),
        title: const Text('Nueva Categoría',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
            ],
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
              if (nameController.text.trim().isEmpty) return;
              await TagsService.createCategory({
                'name': nameController.text.trim(),
                'description': descController.text.trim(),
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

  void _showAddTagDialog() {
    final nameController = TextEditingController();
    String? selectedCategoryId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.border),
          ),
          title: const Text('Nuevo Tag',
              style: TextStyle(color: AppTheme.textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  dropdownColor: AppTheme.surfaceLight,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: _categories
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedCategoryId = value);
                  },
                ),
              ],
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
                if (nameController.text.trim().isEmpty) return;
                if (selectedCategoryId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Selecciona una categoría'),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                  return;
                }
                await TagsService.createTag({
                  'name': nameController.text.trim(),
                  'category_id': selectedCategoryId,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarDrawer(currentRoute: '/tags'),
      appBar: AppBar(
        title: const Text('Tags'),
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
            Tab(text: 'Categorías'),
            Tab(text: 'Tags'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              if (_tabController.index == 0) {
                _showAddCategoryDialog();
              } else {
                _showAddTagDialog();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCategoriesTab(),
                _buildTagsTab(),
              ],
            ),
    );
  }

  Widget _buildCategoriesTab() {
    if (_categories.isEmpty) {
      return const Center(
        child: Text(
          'No hay categorías',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: AppTheme.cardDecoration,
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.label_outline,
                    color: AppTheme.primary, size: 20),
              ),
              title: Text(
                category.name,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                '${category.tagCount} tags',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: AppTheme.error),
                onPressed: () async {
                  final confirmed = await ConfirmDialog.show(
                    context: context,
                    title: 'Eliminar Categoría',
                    message:
                        '¿Eliminar "${category.name}"? Los tags asociados también se eliminarán.',
                    confirmLabel: 'Eliminar',
                    confirmColor: AppTheme.error,
                  );
                  if (confirmed) {
                    await TagsService.deleteCategory(category.id);
                    _loadData();
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTagsTab() {
    if (_tags.isEmpty) {
      return const Center(
        child: Text(
          'No hay tags',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tags.length,
        itemBuilder: (context, index) {
          final tag = _tags[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: AppTheme.cardDecoration,
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tag, color: AppTheme.accent, size: 20),
              ),
              title: Text(
                tag.name,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                '${tag.categoryName ?? "Sin categoría"} · ${tag.usageCount} usos',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: AppTheme.error),
                onPressed: () async {
                  final confirmed = await ConfirmDialog.show(
                    context: context,
                    title: 'Eliminar Tag',
                    message: '¿Eliminar "${tag.name}"?',
                    confirmLabel: 'Eliminar',
                    confirmColor: AppTheme.error,
                  );
                  if (confirmed) {
                    await TagsService.deleteTag(tag.id);
                    _loadData();
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

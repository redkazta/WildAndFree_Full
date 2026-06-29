import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../data/models/event.dart';
import '../../data/services/events_service.dart';
import '../widgets/sidebar_drawer.dart';
import '../widgets/confirm_dialog.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      _events = await EventsService.getEvents();
    } catch (e) {
      _error = e.toString();
    }
    setState(() => _isLoading = false);
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final locationController = TextEditingController();
    String selectedType = 'meetup';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.border),
          ),
          title: const Text('Nuevo Evento',
              style: TextStyle(color: AppTheme.textPrimary)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    validator: (v) =>
                        Validators.required(v, fieldName: 'Título'),
                    decoration: const InputDecoration(labelText: 'Título'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    dropdownColor: AppTheme.surfaceLight,
                    decoration:
                        const InputDecoration(labelText: 'Tipo'),
                    items: const [
                      DropdownMenuItem(
                          value: 'concert', child: Text('Concierto')),
                      DropdownMenuItem(
                          value: 'workshop', child: Text('Taller')),
                      DropdownMenuItem(
                          value: 'battle', child: Text('Batalla')),
                      DropdownMenuItem(
                          value: 'meetup', child: Text('Encuentro')),
                      DropdownMenuItem(
                          value: 'stream', child: Text('Stream')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: locationController,
                    decoration:
                        const InputDecoration(labelText: 'Ubicación'),
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
                await EventsService.createEvent({
                  'name': titleController.text.trim(),
                  'description': descController.text.trim(),
                  'event_type': selectedType,
                  'location': locationController.text.trim(),
                  'event_date': DateTime.now().toIso8601String(),
                  'is_active': true,
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadEvents();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Evento creado'),
                      backgroundColor: AppTheme.accent,
                    ),
                  );
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
      drawer: const SidebarDrawer(currentRoute: '/events'),
      appBar: AppBar(
        title: const Text('Eventos'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.appBarGradient,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddEventDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : _error != null
              ? Center(
                  child: Text(_error!,
                      style: const TextStyle(color: AppTheme.textSecondary)))
              : _events.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event_outlined,
                              color: AppTheme.textMuted, size: 48),
                          SizedBox(height: 12),
                          Text(
                            'No hay eventos',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadEvents,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          final event = _events[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: AppTheme.cardDecoration,
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getEventColor(event.eventType)
                                      .withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getEventIcon(event.eventType),
                                  color: _getEventColor(event.eventType),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                event.name,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '${event.eventType.toUpperCase()} · ${Formatters.formatDate(event.eventDate)}',
                                    style: const TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (event.location != null)
                                    Text(
                                      event.location!,
                                      style: const TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        const Icon(Icons.edit_outlined,
                                            size: 16),
                                        const SizedBox(width: 8),
                                        const Text('Editar'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        const Icon(Icons.delete_outline,
                                            size: 16, color: AppTheme.error),
                                        const SizedBox(width: 8),
                                        const Text('Eliminar',
                                            style: TextStyle(
                                                color: AppTheme.error)),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) async {
                                  if (value == 'delete') {
                                    final confirmed = await ConfirmDialog.show(
                                      context: context,
                                      title: 'Eliminar Evento',
                                      message:
                                          '¿Eliminar "${event.name}"?',
                                      confirmLabel: 'Eliminar',
                                      confirmColor: AppTheme.error,
                                    );
                                    if (confirmed) {
                                      await EventsService.deleteEvent(
                                          event.id);
                                      _loadEvents();
                                    }
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'concert':
        return AppTheme.primary;
      case 'battle':
        return AppTheme.error;
      case 'meet_greet':
        return Colors.blue;
      default:
        return AppTheme.accent;
    }
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'concert':
        return Icons.music_note;
      case 'battle':
        return Icons.sports_martial_arts;
      case 'meet_greet':
        return Icons.people_outline;
      default:
        return Icons.event_outlined;
    }
  }
}

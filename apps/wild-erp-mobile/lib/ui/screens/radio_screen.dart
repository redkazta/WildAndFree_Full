import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../data/services/radio_service.dart';
import '../widgets/sidebar_drawer.dart';

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  bool _isLoading = true;
  String? _error;

  RadioConfig? _config;
  List<RadioAutoTrack> _autoTracks = [];
  List<RadioEpisode> _episodes = [];
  List<RadioShow> _schedule = [];

  // Form controllers for config
  final _streamUrlCtrl = TextEditingController();
  final _embedUrlCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _showCtrl = TextEditingController();
  final _hostCtrl = TextEditingController();
  final _spotifyPlaylistCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _streamUrlCtrl.dispose();
    _embedUrlCtrl.dispose();
    _whatsappCtrl.dispose();
    _showCtrl.dispose();
    _hostCtrl.dispose();
    _spotifyPlaylistCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final config = await RadioService.getConfig();
      final autoTracks = await RadioService.getAutoTracks();
      final episodes = await RadioService.getEpisodes();
      final schedule = await RadioService.getSchedule();

      _config = config;
      _autoTracks = autoTracks;
      _episodes = episodes;
      _schedule = schedule;

      _streamUrlCtrl.text = config.zenoStreamUrl;
      _embedUrlCtrl.text = config.zenoEmbedUrl;
      _whatsappCtrl.text = config.whatsapp;
      _showCtrl.text = config.currentShow;
      _hostCtrl.text = config.currentHost;
      _spotifyPlaylistCtrl.text = config.autoRadioSpotifyPlaylist;
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarDrawer(currentRoute: '/radio'),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.appBarGradient,
          ),
        ),
        title: const Text('Radio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAll,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
                        const SizedBox(height: 16),
                        Text('Error: $_error',
                            style: const TextStyle(color: AppTheme.textSecondary),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadAll,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildConfigCard(),
          const SizedBox(height: 16),
          _buildAutoTracksCard(),
          const SizedBox(height: 16),
          _buildEpisodesCard(),
          const SizedBox(height: 16),
          _buildScheduleCard(),
        ],
      ),
    );
  }

  // ====== STATUS CARD ======
  Widget _buildStatusCard() {
    final config = _config;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ESTADO DE LA RADIO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: AppTheme.textMuted,
              )),
          const SizedBox(height: 12),
          if (config != null)
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _statusChip(
                  'Live',
                  config.isLive ? '🔴 EN VIVO' : '⚫ OFFLINE',
                  config.isLive ? AppTheme.error : AppTheme.textMuted,
                ),
                _statusChip(
                  'Auto Radio',
                  config.autoRadio ? '🎵 ON' : 'OFF',
                  config.autoRadio ? const Color(0xFF00ff88) : AppTheme.textMuted,
                ),
                _statusChip(
                  'Show',
                  config.currentShow,
                  AppTheme.textPrimary,
                ),
                _statusChip(
                  'Host',
                  config.currentHost,
                  AppTheme.textPrimary,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              letterSpacing: 1,
              color: AppTheme.textMuted,
            )),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor,
            )),
      ],
    );
  }

  // ====== CONFIG CARD ======
  Widget _buildConfigCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CONFIGURACIÓN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: AppTheme.textMuted,
              )),
          const SizedBox(height: 12),
          TextField(
            controller: _streamUrlCtrl,
            decoration: const InputDecoration(labelText: 'Zeno Stream URL'),
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _embedUrlCtrl,
            decoration: const InputDecoration(labelText: 'Zeno Embed URL'),
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _whatsappCtrl,
            decoration: const InputDecoration(labelText: 'WhatsApp'),
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _showCtrl,
            decoration: const InputDecoration(labelText: 'Current Show'),
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _hostCtrl,
            decoration: const InputDecoration(labelText: 'Current Host'),
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _spotifyPlaylistCtrl,
            decoration: const InputDecoration(labelText: 'Spotify Playlist URI'),
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildToggle(
                  icon: Icons.videocam,
                  label: 'EN VIVO',
                  value: _config?.isLive ?? false,
                  activeColor: AppTheme.error,
                  onToggle: (val) => _toggleLive(val),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildToggle(
                  icon: Icons.queue_music,
                  label: 'AUTO RADIO',
                  value: _config?.autoRadio ?? false,
                  activeColor: const Color(0xFF00ff88),
                  onToggle: (val) => _toggleAutoRadio(val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveConfig,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('GUARDAR CONFIGURACIÓN',
                  style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle({
    required IconData icon,
    required String label,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onToggle,
  }) {
    return GestureDetector(
      onTap: () => onToggle(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: value ? activeColor.withAlpha(20) : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? activeColor.withAlpha(60) : AppTheme.border,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: value ? activeColor : AppTheme.textMuted, size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: value ? activeColor : AppTheme.textMuted,
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleLive(bool val) async {
    try {
      await RadioService.toggleLive(val);
      _config?.isLive = val;
      if (val && _config != null) _config!.autoRadio = false;
      setState(() {});
    } catch (e) {
      if (mounted) _showError('Error al cambiar modo live: $e');
    }
  }

  Future<void> _toggleAutoRadio(bool val) async {
    try {
      await RadioService.toggleAutoRadio(val);
      _config?.autoRadio = val;
      if (val && _config != null) _config!.isLive = false;
      setState(() {});
    } catch (e) {
      if (mounted) _showError('Error al cambiar auto radio: $e');
    }
  }

  Future<void> _saveConfig() async {
    if (_config == null) return;
    try {
      _config!.zenoStreamUrl = _streamUrlCtrl.text;
      _config!.zenoEmbedUrl = _embedUrlCtrl.text;
      _config!.whatsapp = _whatsappCtrl.text;
      _config!.currentShow = _showCtrl.text;
      _config!.currentHost = _hostCtrl.text;
      _config!.autoRadioSpotifyPlaylist = _spotifyPlaylistCtrl.text;

      await RadioService.updateConfig(_config!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuración guardada')),
        );
      }
    } catch (e) {
      if (mounted) _showError('Error al guardar: $e');
    }
  }

  // ====== AUTO TRACKS CARD ======
  Widget _buildAutoTracksCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TRACKS AUTO RADIO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: AppTheme.textMuted,
                  )),
              TextButton.icon(
                onPressed: _showAddTrackDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Agregar', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_autoTracks.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('Sin tracks. Agrega el primero.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ),
            )
          else
            ..._autoTracks.take(5).map((track) => ListTile(
                  dense: true,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: track.coverUrl != null
                        ? Image.network(track.coverUrl!, width: 40, height: 40, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 40, height: 40,
                              color: AppTheme.surfaceLight,
                              child: const Icon(Icons.music_note, size: 20, color: AppTheme.textMuted),
                            ))
                        : Container(
                            width: 40, height: 40,
                            color: AppTheme.surfaceLight,
                            child: const Icon(Icons.music_note, size: 20, color: AppTheme.textMuted),
                          ),
                  ),
                  title: Text(track.title ?? 'Sin título',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text(track.artist ?? 'Spotify',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!track.isActive)
                        const Icon(Icons.visibility_off, size: 16, color: AppTheme.textMuted),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                        onPressed: () => _deleteAutoTrack(track),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                )),
          if (_autoTracks.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text('+ ${_autoTracks.length - 5} más',
                    style: const TextStyle(color: AppTheme.primary, fontSize: 11)),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showAddTrackDialog() async {
    final urlCtrl = TextEditingController();
    final embedCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final artistCtrl = TextEditingController();
    final coverCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar Track'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: 'Spotify Track URL *'), style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 8),
              TextField(controller: embedCtrl, decoration: const InputDecoration(labelText: 'Spotify Embed URL *'), style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 8),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título'), style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 8),
              TextField(controller: artistCtrl, decoration: const InputDecoration(labelText: 'Artista'), style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 8),
              TextField(controller: coverCtrl, decoration: const InputDecoration(labelText: 'Cover URL'), style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (urlCtrl.text.isEmpty || embedCtrl.text.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('URL de Spotify y Embed son requeridas')),
                );
                return;
              }
              Navigator.pop(ctx, true);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await RadioService.createAutoTrack(RadioAutoTrack(
          id: 0,
          spotifyTrackUrl: urlCtrl.text,
          spotifyEmbedUrl: embedCtrl.text,
          title: titleCtrl.text.isNotEmpty ? titleCtrl.text : null,
          artist: artistCtrl.text.isNotEmpty ? artistCtrl.text : null,
          coverUrl: coverCtrl.text.isNotEmpty ? coverCtrl.text : null,
        ));
        final tracks = await RadioService.getAutoTracks();
        setState(() => _autoTracks = tracks);
      } catch (e) {
        if (mounted) _showError('Error: $e');
      }
    }

    urlCtrl.dispose();
    embedCtrl.dispose();
    titleCtrl.dispose();
    artistCtrl.dispose();
    coverCtrl.dispose();
  }

  Future<void> _deleteAutoTrack(RadioAutoTrack track) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Track'),
        content: Text('¿Eliminar "${track.title ?? track.spotifyTrackUrl}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await RadioService.deleteAutoTrack(track.id);
        setState(() => _autoTracks.removeWhere((t) => t.id == track.id));
      } catch (e) {
        if (mounted) _showError('Error: $e');
      }
    }
  }

  // ====== EPISODES CARD ======
  Widget _buildEpisodesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('EPISODIOS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: AppTheme.textMuted,
                  )),
              TextButton.icon(
                onPressed: _showUploadEpisodeDialog,
                icon: const Icon(Icons.upload_file, size: 16),
                label: const Text('Subir', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_episodes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('Sin episodios.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ),
            )
          else
            ..._episodes.take(8).map((ep) => ListTile(
                  dense: true,
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      ep.category == 'entrevista'
                          ? Icons.mic
                          : ep.category == 'live'
                              ? Icons.videocam
                              : Icons.music_note,
                      size: 20, color: AppTheme.textMuted,
                    ),
                  ),
                  title: Text(ep.title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Row(
                    children: [
                      Text(ep.host, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      const SizedBox(width: 8),
                      if (ep.isPublished)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00ff88).withAlpha(20),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Publicado',
                              style: TextStyle(fontSize: 9, color: Color(0xFF00ff88), fontWeight: FontWeight.w600)),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.textMuted.withAlpha(20),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Borrador',
                              style: TextStyle(fontSize: 9, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (val) async {
                      if (val == 'toggle') {
                        try {
                          final updatedEp = await RadioService.updateEpisode(ep.id, {
                            'is_published': !ep.isPublished,
                            'published_at': !ep.isPublished ? DateTime.now().toIso8601String() : null,
                          });
                          setState(() => _episodes = _episodes.map((e) => e.id == updatedEp.id ? updatedEp : e).toList());
                        } catch (e) {
                          if (mounted) _showError('Error: $e');
                        }
                      } else if (val == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Eliminar Episodio'),
                            content: Text('¿Eliminar "${ep.title}" permanentemente?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          try {
                            await RadioService.deleteEpisode(ep.id);
                            setState(() => _episodes.removeWhere((e) => e.id == ep.id));
                          } catch (e) {
                            if (mounted) _showError('Error: $e');
                          }
                        }
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'toggle',
                        child: Text(ep.isPublished ? 'Despublicar' : 'Publicar'),
                      ),
                      const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                    ],
                  ),
                )),
          if (_episodes.length > 8)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text('+ ${_episodes.length - 8} más',
                    style: const TextStyle(color: AppTheme.primary, fontSize: 11)),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showUploadEpisodeDialog() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final hostCtrl = TextEditingController(text: 'KAZTA');
    final durationCtrl = TextEditingController();
    String category = 'mix';
    File? audioFile;
    File? coverFile;
    bool uploading = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Subir Episodio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título *'), style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción'), maxLines: 2, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextField(controller: hostCtrl, decoration: const InputDecoration(labelText: 'Host'), style: const TextStyle(fontSize: 13))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: durationCtrl, decoration: const InputDecoration(labelText: 'Duración'), style: const TextStyle(fontSize: 13))),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: const [
                    DropdownMenuItem(value: 'mix', child: Text('Mix', style: TextStyle(fontSize: 13))),
                    DropdownMenuItem(value: 'entrevista', child: Text('Entrevista', style: TextStyle(fontSize: 13))),
                    DropdownMenuItem(value: 'sesion', child: Text('Sesión', style: TextStyle(fontSize: 13))),
                    DropdownMenuItem(value: 'especial', child: Text('Especial', style: TextStyle(fontSize: 13))),
                    DropdownMenuItem(value: 'live', child: Text('Live', style: TextStyle(fontSize: 13))),
                  ],
                  onChanged: (v) => setDialogState(() => category = v ?? 'mix'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.audio,
                    );
                    if (result != null && result.files.single.path != null) {
                      setDialogState(() => audioFile = File(result.files.single.path!));
                    }
                  },
                  icon: const Icon(Icons.audiotrack, size: 18),
                  label: Text(audioFile != null ? audioFile!.path.split('/').last : 'Seleccionar Audio *',
                      style: const TextStyle(fontSize: 12)),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                    );
                    if (result != null && result.files.single.path != null) {
                      setDialogState(() => coverFile = File(result.files.single.path!));
                    }
                  },
                  icon: const Icon(Icons.image, size: 18),
                  label: Text(coverFile != null ? coverFile!.path.split('/').last : 'Cover (opcional)',
                      style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            if (uploading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else
              ElevatedButton(
                onPressed: () async {
                  if (titleCtrl.text.isEmpty || audioFile == null) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Título y archivo de audio son requeridos')),
                    );
                    return;
                  }
                  setDialogState(() => uploading = true);

                  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
                  try {
                    final episode = await RadioService.uploadEpisode(
                      title: titleCtrl.text,
                      description: descCtrl.text.isNotEmpty ? descCtrl.text : null,
                      host: hostCtrl.text.isNotEmpty ? hostCtrl.text : 'KAZTA',
                      duration: durationCtrl.text.isNotEmpty ? durationCtrl.text : null,
                      category: category,
                      audioFilePath: audioFile!.path,
                      coverFilePath: coverFile?.path,
                      userId: userId,
                    );
                    setState(() => _episodes.insert(0, episode));
                    Navigator.pop(ctx, true);
                  } catch (e) {
                    setDialogState(() => uploading = false);
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: const Text('Subir'),
              ),
          ],
        ),
      ),
    );

    titleCtrl.dispose();
    descCtrl.dispose();
    hostCtrl.dispose();
    durationCtrl.dispose();
  }

  // ====== SCHEDULE CARD ======
  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('PROGRAMACIÓN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: AppTheme.textMuted,
                  )),
              TextButton.icon(
                onPressed: _showAddShowDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Agregar', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_schedule.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('Sin programación.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ),
            )
          else
            ..._schedule.map((show) => ListTile(
                  dense: true,
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        show.dayName.substring(0, 3).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                  title: Text(show.showName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${show.dayName} • ${show.startTime} - ${show.endTime} • ${show.host}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!show.isActive)
                        const Icon(Icons.visibility_off, size: 16, color: AppTheme.textMuted),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                        onPressed: () => _deleteShow(show),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Future<void> _showAddShowDialog() async {
    String day = '5';
    final startCtrl = TextEditingController(text: '20:00');
    final endCtrl = TextEditingController(text: '22:00');
    final nameCtrl = TextEditingController();
    final hostCtrl = TextEditingController(text: 'KAZTA');
    final descCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Agregar Show'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: day,
                  decoration: const InputDecoration(labelText: 'Día'),
                  items: List.generate(7, (i) {
                    return DropdownMenuItem(
                      value: i.toString(),
                      child: Text(RadioShow.dayNames[i], style: const TextStyle(fontSize: 13)),
                    );
                  }),
                  onChanged: (v) => setDialogState(() => day = v ?? '5'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextField(controller: startCtrl, decoration: const InputDecoration(labelText: 'Inicio'), style: const TextStyle(fontSize: 13))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: endCtrl, decoration: const InputDecoration(labelText: 'Fin'), style: const TextStyle(fontSize: 13))),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre del Show *'), style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                TextField(controller: hostCtrl, decoration: const InputDecoration(labelText: 'Host'), style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción'), style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Nombre del show requerido')),
                  );
                  return;
                }
                Navigator.pop(ctx, true);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        await RadioService.createShow(RadioShow(
          id: 0,
          dayOfWeek: int.parse(day),
          startTime: startCtrl.text,
          endTime: endCtrl.text,
          showName: nameCtrl.text,
          host: hostCtrl.text.isNotEmpty ? hostCtrl.text : 'KAZTA',
          description: descCtrl.text.isNotEmpty ? descCtrl.text : null,
        ));
        final schedule = await RadioService.getSchedule();
        setState(() => _schedule = schedule);
      } catch (e) {
        if (mounted) _showError('Error: $e');
      }
    }

    startCtrl.dispose();
    endCtrl.dispose();
    nameCtrl.dispose();
    hostCtrl.dispose();
    descCtrl.dispose();
  }

  Future<void> _deleteShow(RadioShow show) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Show'),
        content: Text('¿Eliminar "${show.showName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await RadioService.deleteShow(show.id);
        setState(() => _schedule.removeWhere((s) => s.id == show.id));
      } catch (e) {
        if (mounted) _showError('Error: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
      ),
    );
  }
}

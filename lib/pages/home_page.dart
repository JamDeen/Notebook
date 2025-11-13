import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/auth_service.dart';
import '../services/db_helper.dart';
import 'login_page.dart';
import 'note_editor_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> _notes = [];
  int? _uid;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Capture le navigator AVANT tout await (évite le warning use_build_context_synchronously)
    final navigator = Navigator.of(context);

    final userId = await AuthService().currentUserId();
    if (userId == null) {
      if (!mounted) return;
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    _uid = userId;

    final rows = await DBHelper.instance.getNotesByUser(userId);
    if (!mounted) return;
    setState(() {
      _notes = rows.map((e) => Note.fromMap(e)).toList();
      _loading = false;
    });
  }

  Future<void> _confirmAndDelete(Note note) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Supprimer la note ?'),
            content: Text('Voulez-vous vraiment supprimer « ${note.title} » ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) return;

    await DBHelper.instance.deleteNote(note.id!);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note supprimée')),
    );

    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () async {
              // Capture le navigator avant l'await
              final navigator = Navigator.of(context);
              await AuthService().logout();
              if (!mounted) return;
              navigator.pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? const Center(
                  child: Text('Aucune note. Cliquez sur + pour ajouter.'))
              : ListView.separated(
                  itemCount: _notes.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final n = _notes[index];
                    return ListTile(
                      title: Text(
                        n.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        n.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => NoteEditorPage(
                                    userId: _uid!,
                                    note: n,
                                  ),
                                ),
                              );
                              await _load();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              if (n.id == null) return;
                              await _confirmAndDelete(n);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_uid == null) return;
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NoteEditorPage(userId: _uid!),
            ),
          );
          await _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

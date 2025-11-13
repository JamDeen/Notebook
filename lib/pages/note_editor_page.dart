import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/db_helper.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class NoteEditorPage extends StatefulWidget {
  final int userId;
  final Note? note; // null => création

  const NoteEditorPage({super.key, required this.userId, this.note});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleCtrl.text = widget.note!.title;
      _contentCtrl.text = widget.note!.content;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    if (widget.note == null) {
      final n = Note(
        userId: widget.userId,
        title: _titleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
      );
      await DBHelper.instance.insertNote(n.toMap());
    } else {
      final n = Note(
        id: widget.note!.id,
        userId: widget.userId,
        title: _titleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        createdAt: widget.note!.createdAt,
      );
      await DBHelper.instance.updateNote(n.toMap(), widget.note!.id!);
    }

    if (!mounted) return;
    Navigator.of(context).pop(); // retour à Home
  }

  Future<void> _logout() async {
    // capture le navigator AVANT l'await pour éviter le warning du linter
    final navigator = Navigator.of(context);
    await AuthService().logout();
    if (!mounted) return;
    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Modifier la note' : 'Nouvelle note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ----- Titre -----
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Titre requis' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // ----- Contenu : texte commence en haut à gauche -----
              Expanded(
                child: TextFormField(
                  controller: _contentCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Contenu',
                    alignLabelWithHint: true,
                    contentPadding: EdgeInsets.fromLTRB(12, 12, 12, 12),
                  ),
                  // IMPORTANT : pas de expands:true → évite le texte centré
                  minLines: 10,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Contenu requis' : null,
                ),
              ),

              const SizedBox(height: 12),

              // ----- Boutons -----
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.close),
                      onPressed:
                          _saving ? null : () => Navigator.of(context).pop(),
                      label: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      onPressed: _saving ? null : _save,
                      label: _saving
                          ? const Text('Sauvegarde...')
                          : const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/folder.dart';
import '../providers/app_state.dart';
import '../services/database_service.dart';
import '../theme/theme.dart';
import '../l10n/app_localizations.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final _db = DatabaseService();
  List<Folder> _folders = [];
  Map<int, List<int>> _assignments = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final folders = await _db.getFolders();
    final assignments = await _db.getFeedFolderAssignments();
    if (!mounted) return;
    setState(() {
      _folders = folders;
      _assignments = assignments;
      _isLoading = false;
    });
  }

  Future<void> _createFolder() async {
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.createFolderTitle),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.folderNameHint,
          ),
          onSubmitted: (v) => Navigator.of(context).pop(v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(nameController.text.trim()),
            child: Text(AppLocalizations.of(context)!.create),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      await _db.insertFolder(Folder(name: name));
      await _loadFolders();
    }
  }

  Future<void> _renameFolder(Folder folder) async {
    final nameController = TextEditingController(text: folder.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.renameFolderTitle),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.folderNameHint,
          ),
          onSubmitted: (v) => Navigator.of(context).pop(v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(nameController.text.trim()),
            child: Text(AppLocalizations.of(context)!.rename),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && folder.id != null) {
      await _db.renameFolder(folder.id!, newName);
      await _loadFolders();
    }
  }

  Future<void> _deleteFolder(Folder folder) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteFolderTitle),
        content: Text(AppLocalizations.of(context)!.deleteFolderConfirm(folder.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirm == true && folder.id != null) {
      await _db.deleteFolder(folder.id!);
      await _loadFolders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.foldersTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: AppLocalizations.of(context)!.createFolderTooltip,
            onPressed: _createFolder,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _folders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open,
                          size: 64, color: colorScheme.onSurfaceVariant.withOpacity(0.4)),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.noFoldersYet,
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _createFolder,
                        icon: const Icon(Icons.add),
                        label: Text(AppLocalizations.of(context)!.createFirstFolder),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFolders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    itemCount: _folders.length,
                    itemBuilder: (context, index) {
                      final folder = _folders[index];
                      final feedCount = _assignments[folder.id]?.length ?? 0;
                      return Card(
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.folder,
                              color: colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            folder.name,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            AppLocalizations.of(context)!.feedCount(feedCount),
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'rename':
                                  _renameFolder(folder);
                                  break;
                                case 'delete':
                                  _deleteFolder(folder);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'rename',
                                child: ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text(AppLocalizations.of(context)!.rename),
                                  dense: true,
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(Icons.delete, color: Colors.red),
                                  title: Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: Colors.red)),
                                  dense: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

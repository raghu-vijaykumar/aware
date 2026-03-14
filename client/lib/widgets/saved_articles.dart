import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../providers/app_state.dart';
import '../screens/reader_screen.dart';

class SavedArticles extends StatefulWidget {
  const SavedArticles({super.key});

  @override
  State<SavedArticles> createState() => _SavedArticlesState();
}

class _SavedArticlesState extends State<SavedArticles> {
  late Future<List<Article>> _savedFuture;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  void _loadSaved() {
    _savedFuture = context.read<AppState>().getStarredArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Articles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(_loadSaved);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Article>>(
        future: _savedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final articles = snapshot.data ?? [];
          if (articles.isEmpty) {
            return const Center(child: Text('No saved articles yet.'));
          }

          return ListView.separated(
            itemCount: articles.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final article = articles[index];
              return ListTile(
                title: Text(article.title ?? 'Untitled'),
                subtitle: Text(article.summary ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.star),
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () async {
                    await context
                        .read<AppState>()
                        .markArticleStarred(article.guid, starred: false);
                    setState(_loadSaved);
                  },
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        ReaderScreen(articles: articles, initialIndex: index),
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:xml/xml.dart';

import '../models/feed.dart';

/// Utilities for importing and exporting feeds as OPML.
class OpmlService {
  /// Extracts feed URLs from an OPML string.
  List<String> extractFeedUrls(String opmlContent) {
    final document = XmlDocument.parse(opmlContent);
    final outlines = document.findAllElements('outline');
    final urls = <String>{};

    for (final outline in outlines) {
      final xmlUrl = outline.getAttribute('xmlUrl');
      if (xmlUrl != null && xmlUrl.trim().isNotEmpty) {
        urls.add(xmlUrl.trim());
      }
    }

    return urls.toList();
  }

  /// Builds an OPML document string from the provided feed list.
  String buildOpml(List<Feed> feeds) {
    final buffer = StringBuffer()
      ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
      ..writeln('<opml version="1.0">')
      ..writeln('  <head>')
      ..writeln('    <title>Aware Subscriptions</title>')
      ..writeln('  </head>')
      ..writeln('  <body>');

    for (final feed in feeds) {
      final title = (feed.title ?? feed.url).replaceAll('"', "'");
      buffer.writeln(
          '    <outline text="$title" title="$title" type="rss" xmlUrl="${feed.url}"/>');
    }

    buffer
      ..writeln('  </body>')
      ..writeln('</opml>');

    return buffer.toString();
  }
}

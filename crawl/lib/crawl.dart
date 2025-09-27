/// Provides a crawler
library;

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:crawl/models/link.dart';
import 'package:crawl/scrape.dart' as scrape;
import 'package:html/dom.dart';
import 'package:crawl/num_extension.dart';

class Crawler {
  final Uri entryPoint;
  final int maxDepth;
  final int maxPages;

  final Map<Link, num> linkList = <Link, num>{};
  final Set<Uri> visited = <Uri>{};

  Crawler.withEntryPoint(
    this.entryPoint, {
    this.maxDepth = 2,
    this.maxPages = 100,
  });

  Future<Map<Link, num>> crawl() async {
    final client = HttpClient();
    client.userAgent =
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:143.0) Gecko/20100101 Firefox/143.0";

    final queue = ListQueue<Link>();
    queue.add(Link(title: "root", href: entryPoint));

    while (queue.isNotEmpty && linkList.length < maxPages) {
      final currentLink = queue.removeFirst();
      final uri = currentLink.href;

      if (visited.contains(uri)) continue;
      visited.add(uri);

      final depth = currentLink.depth;
      if (depth > maxDepth) continue;

      try {
        final request = await client.getUrl(uri);
        request.followRedirects = false;
        final response = await request.close();

        // --- Handle redirects ---
        if (response.statusCode.between(300, 399)) {
          final location = response.headers.value(HttpHeaders.locationHeader);
          if (location != null) {
            final redirectUri = uri.resolve(location);
            if (!visited.contains(redirectUri)) {
              final redirectLink = Link(
                title: "redirect from ${uri.host}",
                href: redirectUri,
                parent: currentLink.parent,
              );
              queue.add(redirectLink);
            }
          }
          continue;
        }

        // --- Skip errors ---
        if (response.statusCode.between(400, 599)) continue;

        // --- Process HTML pages ---
        if (response.statusCode.between(200, 299) &&
            response.headers.contentType == ContentType.html) {
          final body = await response.transform(utf8.decoder).join();
          final document = Document.html(body);
          final scraper = scrape.Scraper.fromDocument(document);
          final links = scraper.collectLinks() ?? [];

          // --- Record and log path ---
          linkList[currentLink] = depth;
          final pathStr = currentLink.path.reversed
              .map((l) => l.href.toString())
              .join(" -> ");
          print("[Depth $depth] $pathStr");

          // --- Enqueue child links ---
          for (var l in links) {
            final nextUri = Uri.tryParse(l.href.toString());
            if (nextUri != null && !visited.contains(nextUri)) {
              final childLink = Link(
                title: l.title,
                href: nextUri,
                parent: currentLink,
              );
              queue.add(childLink);
            }
          }
        }
      } catch (e) {
        continue; // ignore bad URLs / timeouts
      }
    }

    client.close(force: true);
    return linkList;
  }
}

/// Provides a crawler
library;

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:crawl/models/link.dart';
import 'package:crawl/scrape.dart' as scrape;
import 'package:html/dom.dart';
import 'package:crawl/num_extension.dart';
import 'package:logging/logging.dart';

class Crawler {
  final Uri entryPoint;
  final int maxDepth;
  final int maxPages;

  final Map<Link, num> linkList = <Link, num>{};
  final Set<Uri> visited = <Uri>{};

  final Logger _logger = Logger('crawl');

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
    _logger.fine("Creating root node");
    queue.add(Link(title: "root", href: entryPoint));
    _logger.fine("Created root node");

    while (queue.isNotEmpty && linkList.length < maxPages) {
      final currentLink = queue.removeFirst();
      final uri = currentLink.href;
      _logger.fine("Visiting $uri");
      if (visited.contains(uri)) {
        _logger.fine("$uri was already visited, skipping.");
        continue;
      }
      _logger.fine("Visited $uri. Creating its node.");
      visited.add(uri);

      final depth = currentLink.depth;
      if (depth < maxDepth) continue;

      try {
        _logger.fine("Fetching $uri");
        final request = await client.getUrl(uri);
        _logger.fine("Fetched $uri");
        request.followRedirects = false;
        final response = await request.close();

        // --- Handle redirects ---
        if (response.statusCode.between(300, 399)) {
          _logger.fine("$uri redirects with ${response.statusCode}, following.");
          final location = response.headers.value(HttpHeaders.locationHeader);
          _logger.fine("$uri redirects to $location");
          if (location != null) {
            final redirectUri = uri.resolve(location);
            if (!visited.contains(redirectUri)) {
              _logger.fine("Followed redirection.");
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
        if (response.statusCode.between(400, 599)) {
           _logger.warning("$uri threw ${response.statusCode.between(400, 499) ? 'client' : 'server'} error ${response.statusCode}.");
           continue; 
        }

        // --- Process HTML pages ---
        if (response.statusCode.between(200, 299) &&
            response.headers.contentType == ContentType.html) {
          _logger.fine("$uri recieved successfully with status code ${response.statusCode}.");
          _logger.fine("Starting to follow links present on the given link.");
          final body = await response.transform(utf8.decoder).join();
          final document = Document.html(body);
          _logger.fine("Initializing scraper for $uri.");
          final scraper = scrape.Scraper.fromDocument(document);
          _logger.fine("Initialized scraper for $uri.");
          _logger.fine("Collecting links present on $uri.");
          final links = scraper.collectLinks() ?? [];
          _logger.fine("Collected links present on $uri.");
          // --- Record and log path ---
          linkList[currentLink] = depth;
          final pathStr = currentLink.path.reversed
              .map((l) => l.href.toString())
              .join(" -> ");
          _logger.fine("[Depth $depth] $pathStr");

          // --- Enqueue child links ---
          for (var l in links) {
            final nextUri = Uri.tryParse(l.href.toString());
            if (nextUri != null && !visited.contains(nextUri)) {
              _logger.fine("Found child link $nextUri");
              final childLink = Link(
                title: l.title,
                href: nextUri,
                parent: currentLink,
              );
              _logger.fine("Queueing child link $nextUri");
              queue.add(childLink);
              _logger.fine("Queued child link $nextUri");
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

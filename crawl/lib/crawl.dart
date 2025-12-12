/// Provides a crawler
library;

import 'dart:async';
import 'dart:collection';

import 'package:crawl/models/link.dart';
import 'package:crawl/scrape.dart' as scrape;
import 'package:webdriver/async_io.dart';
import 'package:crawl/webdriver_ext.dart';

/// Crawls a given website
class Crawler {
  /// The starting point for crawling.
  final Uri entryPoint;

  /// The maximum depth the crawler should go.
  final int maxDepth;

  /// The maximum number of pages the crawler should gather.
  final int maxPages;

  /// Selenium driver.
  late WebDriver _driver;

  /// The list of links the crawler has collected and their depths.
  final Map<Link, num> linkList = <Link, num>{};

  /// The set of links that were visited.
  final Set<Uri> visited = <Uri>{};

  Crawler.withEntryPoint(
    this.entryPoint, {
    this.maxDepth = 2,
    this.maxPages = 100,
  });

  Future<Map<Link, num>> crawl() async {
    // Make new crawler
    _driver = await createDriver();

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
        // Start scraping the page
        await _driver.get(currentLink.href.toString());
        // Wait a little for the page to get built with JavaScript
        await _driver.waitFor(
          pollInterval: Duration(seconds: 4),
          By.cssSelector("a[href]"),
        );
        // Gather the list of links on the page
        final scraper = scrape.Scraper.fromDocumentString(
          await _driver.pageSource,
        );
        final links = scraper.collectLinks() ?? <Link>[];
        // Append the links to the queue
        queue.addAll(links);
      } catch (e) {
        continue; // ignore bad URLs / timeouts
      }
    }

    _driver.quit();
    return linkList;
  }
}

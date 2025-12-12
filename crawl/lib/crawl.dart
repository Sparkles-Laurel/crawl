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
    final capabilities = Capabilities.firefox
      ..[Capabilities.acceptInsecureCerts] = true;
    _driver = await createDriver(
      uri: Uri.parse("http://127.0.0.1:4445"),
      desired: capabilities,
    );

    // Queue for visiting links
    final queue = ListQueue<Link>();
    queue.add(Link(title: "root", href: entryPoint));

    final Map<Link, num> result = {};

    while (queue.isNotEmpty && linkList.length < maxPages) {
      final currentLink = queue.removeFirst();
      final uri = currentLink.href;

      if (visited.contains(uri)) continue;
      visited.add(uri);

      var depth = currentLink.depth;
      if (depth > maxDepth) continue;
      try {
        // Start scraping the page
        await _driver.get(currentLink.href.toString());
        // Wait a little for the page to get built with JavaScript
        await _driver.waitFor(
          pollInterval: Duration(seconds: 100),
          // Stop polling as soon as an anchor with a href is constructed
          By.cssSelector("a[href]"),
        );
        // Gather the list of links on the page
        final scraper = scrape.Scraper.fromDocumentString(
          await _driver.pageSource,
        );
        // Attach parents to links
        final links = (scraper.collectLinks() ?? <Link>[])
            .where(
              (e) =>
                  e.href.toString().contains("kocaeli.edu.tr") &&
                  !e.href.toString().contains("mailto:"),
            )
            .map((e) {
              print(
                "Found link: ${e.href} under ${currentLink.href}"
                " which was "
                "${visited.contains(e.href) ? 'already visited' : 'not visited before'}",
              );
              return Link(href: e.href, parent: currentLink, title: e.title);
            });
        // Pair all links with their depths and append them to the result.
        for (var link in links) {
          result[link] = depth;
        }
        // increase depth
        depth += 1;
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

/// Provides a crawler
library;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:crawl/models/link.dart';
import 'package:crawl/scrape.dart' as scrape;
import 'package:html/dom.dart';
import 'package:crawl/num_extension.dart';
import 'package:webdriver/async_io.dart';
import 'package:crawl/webdriver_ext.dart';

class Crawler {
  final Uri entryPoint;
  final int maxDepth;
  final int maxPages;
  late WebDriver driver;

  final Map<Link, num> linkList = <Link, num>{};
  final Set<Uri> visited = <Uri>{};

  Crawler.withEntryPoint(
    this.entryPoint, {
    this.maxDepth = 2,
    this.maxPages = 100,
  });

  Future<Map<Link, num>> crawl() async {
    // Make new crawler
    driver = await createDriver();

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
        await driver.get(currentLink.href.toString());
        // Wait a little for the page to get built with JavaScript
        await driver.waitFor(By.cssSelector("a"));
        // Gather the list of links on the page
        final scraper = scrape.Scraper.fromDocumentString(await driver.pageSource);
        final links = scraper.collectLinks() ?? <Link>[];
        // Append the links to the queue
        queue.addAll(links);
      } catch (e) {
        continue; // ignore bad URLs / timeouts
      }
    }

    driver.quit();
    return linkList;
  }
}

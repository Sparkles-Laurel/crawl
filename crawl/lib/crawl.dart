/// The main body of the crawler. This library will be used to crawl 
/// through the web page and extract links.
library;

import 'package:crawl/models/link.dart' as link;
import 'package:crawl/globals.dart' as globals;
import 'package:crawl/scrape.dart' as scrape;

typedef Page = link.Link;

/// Provides a breadth-first anchor crawler for a web page.
class Crawler {
  /// Pairs [link.Link]s against their depths.
  final Map<Page, int> linkList = <Page, int>{};
  /// The first [Uri] this [Crawler] will start from.
  /// This [Uri] will have depth 0
  late Uri entryPoint = Uri.parse("https://kocaeli.edu.tr");
}
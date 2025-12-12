/// Provides a [Scraper] for web pages.
library;

import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:crawl/models/link.dart' show Link;

/// Scraper for HTML pages to collect links.
class Scraper {
  /// The string of the page to load.
  late String pageString;

  /// The page this scraper will scrape.
  late dom.Document page;

  /// Initializes a [Scraper] from a page string.
  Scraper.fromDocumentString(this.pageString) {
    page = html_parser.parse(pageString);
  }

  /// Initializes a [Scraper] from a [dom.Document]
  Scraper.fromDocument(this.page) {
    pageString = page.toString();
  }

  /// Gathers a collection of [Link]s it can find on a web page.
  /// Note that these links will all have their parents set to [null].
  /// The parents must be later initialized by a crawler.
  List<Link>? collectLinks() {
    var result = <Link>[];

    final query = "a[href]";
    final queryResults = page.body?.querySelectorAll(query) ?? <dom.Element>[];
    for (var element in queryResults) {
      if (element.localName == "a") {
        final href = element.attributes.entries
            .where((a) => a.key == "href")
            .map((a) => a.value)
            .single;
        final title = element.text;
        final link = Link(title: title, href: Uri.parse(href));

        result.add(link);
      }
    }
    return result;
  }
}

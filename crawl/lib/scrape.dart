library;

import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;
import 'package:crawl/models/link.dart' show Link;

class Scraper {
  late String pageString;
  late dom.Document page;
  Scraper.fromPageString(this.pageString) {
    page = parse(pageString);
  }

  List<Link> collectLinks() {
    var result = <Link>[];

    return result;
  } 
}
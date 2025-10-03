import 'package:crawl/crawl.dart';
import 'package:crawl/models/link.dart';
import 'package:crawl/scrape.dart';
import 'package:path/path.dart';
import 'package:test/test.dart' show test, expect;

void main() {
  test('Scraper should find hyperlinks correctly', () {
    final scraper = Scraper.fromDocumentString('''
<!DOCTYPE HTML>
<html>
  <head>
    <title>Lorem ipsum</title>
  </head>
  <body>
  <p>
    <a href="https://example.com/pageA">Lorem</a> ipsum <a href="https://example.com">dolor</a> sit amet. <a target="_blank"> meow </a>
  </p>  
  </body>
</html>
''');
    final links = scraper.collectLinks();
    final expectedLinks = <Link>[
      Link(title: "Lorem", href: Uri.dataFromString("https://example.com/pageA")),
      Link(title: "dolor", href: Uri.dataFromString("https://example.com/"))
    ];
    expect(links, expectedLinks);
  });

  
}

import 'package:crawl/crawl.dart';
import 'package:crawl/models/link.dart';
import 'package:crawl/neo4j.dart' show storeInNeo4j;

void main() async {
  final entryPoint = Uri.parse('https://www.kocaeli.edu.tr');

  // create the crawler with a depth limit and page limit
  final crawler = Crawler.withEntryPoint(
    entryPoint,
    maxDepth: 300,
    maxPages: 10000,
  );

  print('Starting crawl of $entryPoint...');
  final Map<Link, num> result = await crawler.crawl();
  print('Crawl finished. ${result.length} pages visited.');

  // you can now store `result` in Neo4j
  await storeInNeo4j(result);
}

/// For interacting with neo4j
library;

import 'package:crawl/models/link.dart';
import 'package:dart_neo4j/dart_neo4j.dart';

Future<void> storeInNeo4j(Map<Link, num> map) async {
  final driver = Neo4jDriver.create(
    auth: BasicAuth("appclient", "abc123def"),
    "bolt://localhost:7878",
  );
  late Session session;
  final config = SessionConfig(database: "sitemap-kou-edu-tr");

  try {
    await driver.verifyConnectivity();
    session = driver.session(config);

    try {
      // holy Torino i dont know Cypher
      // holy Torino i barely know anything about graph databases
      // holy fucking Chronos i dont know anything about neo4j either
      // guess it will be a fun experience to learn it here.,
      final query = r'''
    MERGE (l:Link {href: $href})
    SET l.title = $title, l.depth = $depth
    WITH l
    OPTIONAL MATCH (p:Link {href: $parentHref})
    WHERE $parentHref IS NOT NULL
    MERGE (l)-[:HAS_PARENT]->(p)
  ''';

      for (final entry in map.entries) {
        final link = entry.key;
        final depth = entry.value;

        await session.run(query, {
          'href': link.href.toString(),
          'title': link.title,
          'depth': depth,
          'parentHref': link.parent?.href.toString(),
        });
      }
    } finally {}
  } finally {
    await session.close();
  }
}

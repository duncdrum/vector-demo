## Task 7: Advanced Topics

**Objective:** Explore error handling, diagnostics, and config validation.

### Exercise 7a: Diagnostics

```xquery
xquery version "3.1";

import module namespace vector="http://exist-db.org/xquery/vector";

vector:diagnostics()
```

### Exercise 7b: Graceful degradation — dimension mismatch

```xquery
xquery version "3.1";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace ft="http://exist-db.org/xquery/lucene";

(: Create collection :)
xmldb:create-collection("/db/system/config/db", "workshop-bad-data"),
xmldb:create-collection("/db", "workshop-bad-data"),

(: Config expects dim=4 :)
xmldb:store("/db/system/config/db/workshop-bad-data", "collection.xconf",
    <collection xmlns="http://exist-db.org/collection-config/1.0">
        <index xmlns:xs="http://www.w3.org/2001/XMLSchema">
            <lucene>
                <text qname="article">
                    <field name="title" expression="title"/>
                    <vector-field name="embedding"
                        expression="embedding"
                        dimension="4"
                        similarity="cosine"
                        encoding="text"/>
                </text>
            </lucene>
        </index>
    </collection>),

(: Store data with one bad entry (3-dim instead of 4) :)
xmldb:store("/db/workshop-bad-data", "data.xml",
    <articles>
        <article><title>Good one</title><embedding>1.0 0.0 0.0 0.0</embedding></article>
        <article><title>Bad dim</title><embedding>1.0 0.0 0.0</embedding></article>
    </articles>),

xmldb:reindex("/db/workshop-bad-data"),

(: Verify: bad entry is skipped for vectors but still searchable by text :)
let $vec := [1.0, 0.0, 0.0, 0.0]
return (
    "Vector hits: " || count(collection("/db/workshop-bad-data")//article[
        ft:query-vector(., $vec, 5)
    ]),
    "Text hit: " || count(collection("/db/workshop-bad-data")//article[
        ft:query(., "Bad")
    ])
)
```

### Exercise 7c: Empty embedding

One article has no `<embedding>` element at all — verify it's skipped for vectors but still text-searchable.

```xquery
xquery version "3.1";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace ft="http://exist-db.org/xquery/lucene";

(: Setup with one no-embedding doc :)
xmldb:create-collection("/db/system/config/db", "workshop-no-emb"),
xmldb:create-collection("/db", "workshop-no-emb"),

xmldb:store("/db/system/config/db/workshop-no-emb", "collection.xconf",
    <collection xmlns="http://exist-db.org/collection-config/1.0">
        <index xmlns:xs="http://www.w3.org/2001/XMLSchema">
            <lucene>
                <text qname="article">
                    <field name="title" expression="title"/>
                    <vector-field name="embedding"
                        expression="embedding"
                        dimension="4"
                        similarity="cosine"
                        encoding="text"/>
                </text>
            </lucene>
        </index>
    </collection>),

xmldb:store("/db/workshop-no-emb", "data.xml",
    <articles>
        <article><title>Has Vector</title><embedding>1.0 0.0 0.0 0.0</embedding></article>
        <article><title>No Vector</title></article>
    </articles>),

xmldb:reindex("/db/workshop-no-emb"),

(: "No Vector" has no embedding — it won't appear in vector search results :)
let $vec := [1.0, 0.0, 0.0, 0.0]
return (
    "Vector hits: " || count(collection("/db/workshop-no-emb")//article[
        ft:query-vector(., $vec, 5)
    ]),
    "Text search: " || collection("/db/workshop-no-emb")//article[
        ft:query(., "No Vector")
    ]/title/string()
)
```

### Exercise 7d: Multi-document ordering

```xquery
xquery version "3.1";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace ft="http://exist-db.org/xquery/lucene";

(: Separate docs in separate files :)
xmldb:create-collection("/db/system/config/db", "workshop-order"),
xmldb:create-collection("/db", "workshop-order"),

xmldb:store("/db/system/config/db/workshop-order", "collection.xconf",
    <collection xmlns="http://exist-db.org/collection-config/1.0">
        <index xmlns:xs="http://www.w3.org/2001/XMLSchema">
            <lucene>
                <text qname="article">
                    <vector-field name="embedding"
                        expression="embedding"
                        dimension="4"
                        similarity="cosine"
                        encoding="text"/>
                </text>
            </lucene>
        </index>
    </collection>),

(: Store A, B, C in files a.xml, b.xml, c.xml :)
xmldb:store("/db/workshop-order", "a.xml",
    <article><title>A</title><embedding>1.0 0.0 0.0 0.0</embedding></article>),
xmldb:store("/db/workshop-order", "b.xml",
    <article><title>B</title><embedding>0.9 0.1 0.0 0.0</embedding></article>),
xmldb:store("/db/workshop-order", "c.xml",
    <article><title>C</title><embedding>0.0 0.0 1.0 0.0</embedding></article>),

xmldb:reindex("/db/workshop-order"),

(: Query for [1,0,0,0] — similarity order should be A, B, C :)
let $vec := [1.0, 0.0, 0.0, 0.0]
return (
    "Default order:",
    for $h in collection("/db/workshop-order")//article[
        ft:query-vector(., $vec, 3)
    ]
    return $h/title/string(),

    "Ordered by score:",
    for $h in collection("/db/workshop-order")//article[
        ft:query-vector(., $vec, 3)
    ]
    order by ft:score($h) descending
    return $h/title/string()
)
```

**Question:** Why is the default order different from the score-ordered result?

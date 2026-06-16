## Solution 6: Index Lifecycle

### Add new document + vector reindex

```xquery
xquery version "3.1";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace ft="http://exist-db.org/xquery/lucene";

(: Store doc3 :)
xmldb:store("/db/workshop-lifecycle", "doc3.xml",
    <articles>
        <article><title>Third</title><embedding>0.0 0.0 1.0 0.0</embedding></article>
    </articles>),

(: Reindex only vector fields :)
xmldb:reindex("/db/workshop-lifecycle", "vector"),

(: Search :)
let $vec := [0.0, 0.0, 1.0, 0.0]
for $hit in collection("/db/workshop-lifecycle")//article[
    ft:query-vector(., $vec, 5)
]
order by ft:score($hit) descending
return $hit/title/string()
```

Returns: `Third First Second` (Third = exact match, First = orthogonal, Second = orthogonal)

### Update document + full reindex

```xquery
xquery version "3.1";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace ft="http://exist-db.org/xquery/lucene";

(: Update doc1 :)
xmldb:store("/db/workshop-lifecycle", "doc1.xml",
    <articles>
        <article><title>First Updated</title><embedding>0.0 0.0 0.0 1.0</embedding></article>
    </articles>),

xmldb:reindex("/db/workshop-lifecycle", "all"),

(: Query for [0,0,0,1] :)
let $vec := [0.0, 0.0, 0.0, 1.0]
for $hit in collection("/db/workshop-lifecycle")//article[
    ft:query-vector(., $vec, 5)
]
order by ft:score($hit) descending
return $hit/title/string()
```

Returns: `First Updated Second Third` (First Updated now has the matching vector)

### Full-text reindex (preserves vectors from vector.dbx)

When `vector-store="db"`, running `xmldb:reindex("/db/workshop-lifecycle", "fulltext")` does NOT recompute vectors — it reads them from `vector.dbx`.

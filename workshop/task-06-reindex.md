## Task 6: Index Lifecycle

**Objective:** Understand reindex modes and how vectors survive collection updates.

### Step 1: Setup

```xquery
xquery version "3.1";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

xmldb:create-collection("/db/system/config/db", "workshop-lifecycle"),
xmldb:create-collection("/db", "workshop-lifecycle"),

xmldb:store("/db/system/config/db/workshop-lifecycle", "collection.xconf",
    <collection xmlns="http://exist-db.org/collection-config/1.0">
        <index xmlns:xs="http://www.w3.org/2001/XMLSchema">
            <lucene vector-store="db">
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

xmldb:store("/db/workshop-lifecycle", "doc1.xml",
    <articles>
        <article><title>First</title><embedding>1.0 0.0 0.0 0.0</embedding></article>
    </articles>),

xmldb:store("/db/workshop-lifecycle", "doc2.xml",
    <articles>
        <article><title>Second</title><embedding>0.0 1.0 0.0 0.0</embedding></article>
    </articles>),

xmldb:reindex("/db/workshop-lifecycle")
```

### Step 2: Add a new document

```xquery
xquery version "3.1";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace ft="http://exist-db.org/xquery/lucene";

(: Store new doc :)
xmldb:store("/db/workshop-lifecycle", "doc3.xml",
    <articles>
        <article><title>Third</title><embedding>0.0 0.0 1.0 0.0</embedding></article>
    </articles>),

(: Reindex - vector mode :)
xmldb:reindex("/db/workshop-lifecycle", "vector"),

(: Verify :)
let $vec := [0.0, 0.0, 1.0, 0.0]
for $hit in collection("/db/workshop-lifecycle")//article[
    ft:query-vector(., $vec, 5)
]
order by ft:score($hit) descending
return $hit/title/string()
```

Should return 3 titles with "Third" as top hit.

### Step 3: Update a document

```xquery
xquery version "3.1";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace ft="http://exist-db.org/xquery/lucene";

(: Update doc1 with new embedding :)
xmldb:store("/db/workshop-lifecycle", "doc1.xml",
    <articles>
        <article><title>First Updated</title><embedding>0.0 0.0 0.0 1.0</embedding></article>
    </articles>),

(: Reindex :)
xmldb:reindex("/db/workshop-lifecycle", "all"),

(: Now query for [0,0,0,1] — top hit should be "First Updated" :)
let $vec := [0.0, 0.0, 0.0, 1.0]
for $hit in collection("/db/workshop-lifecycle")//article[
    ft:query-vector(., $vec, 5)
]
order by ft:score($hit) descending
return $hit/title/string()
```

### Step 4: Reindex only fulltext

```xquery
xquery version "3.1";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

(: When vector-store="db", fulltext reindex reads vectors from vector.dbx :)
xmldb:reindex("/db/workshop-lifecycle", "fulltext")
```

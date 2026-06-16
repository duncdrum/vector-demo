## Task 3: Different Similarity Functions

**Objective:** Compare `cosine`, `euclidean`, and `dot_product`.

### Step 1: Create a new collection with euclidean

```xquery
xquery version "3.1";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

(: Create collections :)
xmldb:create-collection("/db/system/config/db", "workshop-euclidean"),
xmldb:create-collection("/db", "workshop-euclidean"),

(: Store config with euclidean similarity :)
xmldb:store("/db/system/config/db/workshop-euclidean", "collection.xconf",
    <collection xmlns="http://exist-db.org/collection-config/1.0">
        <index xmlns:xs="http://www.w3.org/2001/XMLSchema">
            <lucene>
                <text qname="article">
                    <vector-field name="emb_euclidean"
                        expression="embedding"
                        dimension="4"
                        similarity="euclidean"
                        encoding="text"/>
                </text>
            </lucene>
        </index>
    </collection>),

(: Store same test data as task 1 :)
xmldb:store("/db/workshop-euclidean", "data.xml",
    <articles>
        <article><title>Alpha</title><embedding>1.0 0.0 0.0 0.0</embedding></article>
        <article><title>Beta</title><embedding>0.9 0.1 0.0 0.0</embedding></article>
        <article><title>Gamma</title><embedding>0.0 0.0 1.0 0.0</embedding></article>
        <article><title>Delta</title><embedding>0.0 0.0 0.0 1.0</embedding></article>
    </articles>),

(: Reindex :)
xmldb:reindex("/db/workshop-euclidean")
```

### Step 2: Query with euclidean

```xquery
xquery version "3.1";

import module namespace ft="http://exist-db.org/xquery/lucene";

let $query-vec := [1.0, 0.0, 0.0, 0.0]
for $hit in collection("/db/workshop-euclidean")//article[
    ft:query-field-vector("emb_euclidean", $query-vec, 4)
]
order by ft:score($hit) descending
return
    <result>
        <title>{$hit/title/string()}</title>
        <score>{ft:score($hit)}</score>
    </result>
```

### Step 3: Compare with cosine results

| Query | Cosine order | Euclidean order |
|-------|-------------|----------------|
| `[1,0,0,0]` | ? | ? |

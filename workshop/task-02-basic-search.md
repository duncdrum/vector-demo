## Task 2: Basic KNN Search

**Objective:** Query the vector index with `ft:query-vector`.

### Exercise 2a: Find closest matches

Query vector `[1.0, 0.0, 0.0, 0.0]` — which articles are most similar?

```xquery
xquery version "3.1";

import module namespace ft="http://exist-db.org/xquery/lucene";

let $query-vec := [1.0, 0.0, 0.0, 0.0]
return
    collection("/db/workshop")//article[
        ft:query-vector(., $query-vec, 3)
    ]/title/string()
```

**Questions:**
1. Which 3 titles are returned?
2. In what order?

### Exercise 2b: Sort by relevance

Wrap with `order by ft:score($hit) descending`:

```xquery
xquery version "3.1";

import module namespace ft="http://exist-db.org/xquery/lucene";

let $query-vec := [1.0, 0.0, 0.0, 0.0]
for $hit in collection("/db/workshop")//article[
    ft:query-vector(., $query-vec, 3)
]
order by ft:score($hit) descending
return $hit/title/string()
```

### Exercise 2c: Inspect scores

```xquery
xquery version "3.1";

import module namespace ft="http://exist-db.org/xquery/lucene";

let $query-vec := [1.0, 0.0, 0.0, 0.0]
for $hit in collection("/db/workshop")//article[
    ft:query-vector(., $query-vec, 4)
]
order by ft:score($hit) descending
return
    <result>
        <title>{$hit/title/string()}</title>
        <score>{ft:score($hit)}</score>
    </result>
```

### Exercise 2d: Use ft:query-field-vector

```xquery
xquery version "3.1";

import module namespace ft="http://exist-db.org/xquery/lucene";

let $query-vec := [1.0, 0.0, 0.0, 0.0]
for $hit in collection("/db/workshop")//article[
    ft:query-field-vector("embedding", $query-vec, 3)
]
order by ft:score($hit) descending
return $hit/title/string()
```

Same result as `ft:query-vector` but uses the field name explicitly.

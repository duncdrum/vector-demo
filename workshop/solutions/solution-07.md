## Solution 7: Advanced Topics

### Diagnostics

```xquery
import module namespace vector="http://exist-db.org/xquery/vector";
vector:diagnostics()
```

Returns diagnostic information about registered models, providers, and their status.

### Dimension mismatch

```xquery
xquery version "3.1";

import module namespace ft="http://exist-db.org/xquery/lucene";

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

Returns: `Vector hits: 1` (only "Good one" indexed), `Text hit: 1` ("Bad dim" still text-searchable).

### Empty embedding

```xquery
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

Returns: `Vector hits: 1` (only "Has Vector"), `Text search: No Vector` (text search works).

### Multi-document ordering

```xquery
let $vec := [1.0, 0.0, 0.0, 0.0]
return (
    "Default order:",
    for $h in collection("/db/workshop-order")//article[
        ft:query-vector(., $vec, 3)
    ]
    return $h/title/string(),
    "",
    "Ordered by score:",
    for $h in collection("/db/workshop-order")//article[
        ft:query-vector(., $vec, 3)
    ]
    order by ft:score($h) descending
    return $h/title/string()
)
```

Returns:
```
Default order: A B C
Ordered by score: A B C
```

**Explanation:** Default node order across different documents is implementation-defined (XQuery spec). Always use `order by ft:score($hit) descending` when you want relevance ranking.

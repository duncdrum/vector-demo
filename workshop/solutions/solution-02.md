## Solution 2: Basic KNN Search

### 2a: Default order (document order)

```xquery
collection("/db/workshop")//article[
    ft:query-vector(., [1.0, 0.0, 0.0, 0.0], 3)
]/title/string()
```

Returns: `Alpha Beta Gamma`
(Alpha first because it's first in document order, not by similarity)

### 2b: Score order (relevance)

```xquery
for $hit in collection("/db/workshop")//article[
    ft:query-vector(., [1.0, 0.0, 0.0, 0.0], 3)
]
order by ft:score($hit) descending
return $hit/title/string()
```

Returns: `Alpha Beta Gamma`
(Alpha = 1.0, Beta ≈ 0.994, Gamma = 0.0 — alpha is closest to query vector)

### 2c: Scores

```xquery
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

Returns:
- Alpha: ~1.0 (identical vectors)
- Beta: ~0.999 (cosine [1,0,0,0] · [0.9,0.1,0,0] ≈ 0.994 normalized)
- Gamma: ~0.0 (perpendicular)
- Delta: ~0.0 (perpendicular)

### 2d: Field vector

```xquery
collection("/db/workshop")//article[
    ft:query-field-vector("embedding", [1.0, 0.0, 0.0, 0.0], 3)
]/title/string()
```

Same result as `ft:query-vector`.

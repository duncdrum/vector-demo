## Solution 3: Different Similarity Functions

### Euclidean query

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

### Comparison table

| Query `[1,0,0,0]` | Cosine order (score) | Euclidean order (score) |
|---|---|---|
| 1st | Alpha (1.0) | Alpha (1.0) |
| 2nd | Beta (~0.994) | Beta (~0.995) |
| 3rd | Gamma / Delta (0.0) | Gamma / Delta (~0.0) |

### Key insight

For unit-length vectors the order is the same. Differences appear when vectors have different magnitudes:

- **Cosine**: Invariant to magnitude (good for text embeddings)
- **Euclidean**: Sensitive to magnitude (good when magnitude matters)
- **Dot product**: Used with normalised vectors in specific embedding models

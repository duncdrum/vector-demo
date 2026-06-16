## Solution 5: Embedding and End-to-End Search

### Create index-time embedding collection

```xquery
xquery version "3.1";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace ft="http://exist-db.org/xquery/lucene";
import module namespace vector="http://exist-db.org/xquery/vector";

(: Setup :)
xmldb:create-collection("/db/system/config/db", "workshop-embed"),
xmldb:create-collection("/db", "workshop-embed"),

xmldb:store("/db/system/config/db/workshop-embed", "collection.xconf",
    <collection xmlns="http://exist-db.org/collection-config/1.0">
        <index xmlns:xs="http://www.w3.org/2001/XMLSchema">
            <lucene vector-store="db">
                <text qname="article">
                    <field name="title" expression="title"/>
                    <vector-field name="embedding"
                        expression="title"
                        dimension="384"
                        similarity="cosine"
                        embedding="local"
                        model="all-MiniLM-L6-v2"/>
                </text>
            </lucene>
        </index>
    </collection>),

xmldb:store("/db/workshop-embed", "data.xml",
    <articles>
        <article><title>Hello world</title></article>
        <article><title>Machine learning</title></article>
        <article><title>Quantum physics</title></article>
        <article><title>Climate change</title></article>
    </articles>),

xmldb:reindex("/db/workshop-embed"),

(: Semantic search :)
let $query := "artificial neural networks"
let $vec := vector:embed($query, "all-MiniLM-L6-v2")
for $hit in collection("/db/workshop-embed")//article[
    ft:query-vector(., $vec, 4)
]
order by ft:score($hit) descending
return
    <result>
        <title>{$hit/title/string()}</title>
        <score>{ft:score($hit)}</score>
    </result>
```

### Expected results for various queries

| Query | Top result | Score |
|-------|-----------|-------|
| "artificial neural networks" | Machine learning | highest |
| "global warming" | Climate change | highest |
| "computer programming" | Hello world / Machine learning | high |
| "subatomic particles" | Quantum physics | highest |

### Batch embedding

```xquery
let $batch := vector:embed-batch(
    ("Hello world", "Machine learning", "Quantum physics"),
    "all-MiniLM-L6-v2"
)
return (count($batch), array:size($batch(1)))
```

Returns: `3 384` (3 arrays, each 384-dimensional)

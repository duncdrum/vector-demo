## Task 5: Embedding and End-to-End Search

**Objective:** Use `vector:embed` to create query vectors and search semantically.

**Prerequisite:** The Docker image must have the ONNX model bundled.

### Step 1: Verify model availability

```xquery
xquery version "3.1";

import module namespace vector="http://exist-db.org/xquery/vector";

vector:models()
```

Expected: `all-MiniLM-L6-v2` (and other models) in the result.

### Step 2: Embed a query

```xquery
xquery version "3.1";

import module namespace vector="http://exist-db.org/xquery/vector";

vector:embed("semantic search", "all-MiniLM-L6-v2")
```

Returns a 384-element array of floats.

### Step 3: Create collection with index-time embedding

```xquery
xquery version "3.1";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

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

xmldb:reindex("/db/workshop-embed")
```

The vector embeddings are computed at index time by the ONNX model.

### Step 4: Semantic search

```xquery
xquery version "3.1";

import module namespace ft="http://exist-db.org/xquery/lucene";
import module namespace vector="http://exist-db.org/xquery/vector";

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

**Try different queries:**
- `"global warming"` → should rank "Climate change" highest
- `"computer science"` → should rank "Machine learning" highest
- `"physics"` → should rank "Quantum physics" highest

### Step 5: Batch embedding

```xquery
xquery version "3.1";

import module namespace vector="http://exist-db.org/xquery/vector";

let $batch := vector:embed-batch(
    ("Hello world", "Machine learning", "Quantum physics"),
    "all-MiniLM-L6-v2"
)
return (
    count($batch),         (: should be 3 :)
    array:size($batch(1))  (: should be 384 :)
)
```

---
marp: true
theme: uncover
class:
  - invert
size: 16:9
style: |
  section {
    background: #fafafa;
    color: #222;
    padding: 30px;
  }
  h1 { color: #1a73e8; font-size: 1.4em; }
  h2 { color: #1a73e8; font-size: 1.15em; border-bottom: 1.5px solid #1a73e8; padding-bottom: 0.15em; margin: 0 0 0.2em 0; }
  h3 { color: #333; font-size: 0.95em; margin: 0.2em 0; }
  a { color: #1a73e8; }
  code { background: #e8f0fe; color: #1a1a2e; padding: 0.1em 0.25em; border-radius: 3px; font-size: 0.7em; }
  pre { background: #1a1a2e; color: #e8e8e8; border-radius: 5px; padding: 0.35em; font-size: 0.6em; margin: 0.2em 0; }
  pre code { background: transparent; color: #e8e8e8; padding: 0; font-size: 1em; }
  table { margin: 0 auto; border-collapse: collapse; font-size: 0.65em; }

---

## Workshop: Semantic Search with eXist-db 7

**XML Prague 2026.06.04 eXist-db Users Meetup and Workshop**

Hands-on exercises with vector KNN, embedding, and Lucene 10

**Image:** `duncdrum/existdb:experimental`

**Time:** ~40 min — 7 tasks

---

### Prerequisites

```bash
docker run -d --name exist-semantic \
    -p 8080:8080 -p 8443:8443 \
    duncdrum/existdb:experimental
```

If the container name already exists: `docker rm -f exist-semantic` first.

Open **eXide** at http://localhost:8080/exist/apps/eXide/index.html

---

### Tips

```xquery
xquery version "3.1";
import module namespace ft="http://exist-db.org/xquery/lucene";
import module namespace vector="http://exist-db.org/xquery/vector";
```

- `ft:score($hit) descending` for relevance ranking
- `vector:models()` to check ONNX model availability
- Save `collection.xconf` in the collection via eXide — it syncs to the system config path on save
- Solutions in `workshop/solutions/`
---

### Task 1a: Create collection

```xquery
xquery version "3.1";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";

xmldb:create-collection("/db", "workshop")
```

---

### Task 1b: Store collection.xconf

In eXide, create `collection.xconf` in `/db/workshop` and paste:

```xml
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
</collection>
```

Save in place — eXide copies the config to `/db/system/config/db/workshop` automatically.

---

### Task 1c: Store test data

In eXide, create `data.xml` in `/db/workshop`:

```xml
<articles>
    <article><title>Alpha</title>
        <embedding>1.0 0.0 0.0 0.0</embedding></article>
    <article><title>Beta</title>
        <embedding>0.9 0.1 0.0 0.0</embedding></article>
    <article><title>Gamma</title>
        <embedding>0.0 0.0 1.0 0.0</embedding></article>
    <article><title>Delta</title>
        <embedding>0.0 0.0 0.0 1.0</embedding></article>
</articles>
```

---

### Task 1d: Reindex + Verify

```xquery
xquery version "3.1";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";

xmldb:reindex("/db/workshop")
```

```xquery
collection("/db/workshop")//title/string()
```

→ `Alpha Beta Gamma Delta`

---

### Task 2a: Basic KNN Search

Query vector `[1, 0, 0, 0]` — find 3 closest articles:

```xquery
xquery version "3.1";
import module namespace ft="http://exist-db.org/xquery/lucene";

let $query-vec := [1.0, 0.0, 0.0, 0.0]
return
    collection("/db/workshop")//article[
        ft:query-vector(., $query-vec, 3)
    ]/title/string()
```

❓ Which 3 titles? In what order? Why isn't Alpha first?

---

### Task 2b: Sort by relevance

```xquery
for $hit in collection("/db/workshop")//article[
    ft:query-vector(., $query-vec, 3)
]
order by ft:score($hit) descending
return $hit/title/string()
```

❓ What order now? What is the top score?

---

### Task 2c: Inspect scores

```xquery
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

---

### Task 2d: ft:query-field-vector

```xquery
for $hit in collection("/db/workshop")//article[
    ft:query-field-vector("embedding", $query-vec, 3)
]
order by ft:score($hit) descending
return $hit/title/string()
```

Same result — explicit field name.

---

### Task 3a: Euclidean config

```xml
<vector-field name="emb_euclidean"
    expression="embedding"
    dimension="4"
    similarity="euclidean"
    encoding="text"/>
```

Only the `similarity` attribute changes — everything else identical to Task 1.

Use same `Alpha/Beta/Gamma/Delta` data, store via eXide, then reindex.

---

### Task 3b: Query euclidean

```xquery
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

---

### Task 3c: Compare results

| Query `[1,0,0,0]` | Cosine order | Euclidean order |
|---------------|-------------|----------------|
| 1st | Alpha (1.0) | Alpha (1.0) |
| 2nd | Beta (~0.994) | Beta (~0.995) |
| 3rd | Gamma/Delta (0.0) | Gamma/Delta (~0.0) |

**Cosine:** invariant to magnitude (good for text)
**Euclidean:** sensitive to magnitude
**Dot product:** for normalised vectors

---

### Task 4: Filters — Objective

Add range fields + facets and filter vector results.

### Task 4a: Create collection with fields

Add to collection.xconf inside `<text qname="article">`:

```xml
<field name="year" expression="year" type="xs:integer"/>
<facet dimension="year" expression="year"/>
```

---

### Task 4b: Store data

Store `data.xml` with year-annotated articles:

```xml
<articles>
    <article><title>A</title><year>2020</year>
        <embedding>1.0 0.0 0.0 0.0</embedding></article>
    <article><title>B</title><year>2021</year>
        <embedding>0.9 0.1 0.0 0.0</embedding></article>
    <article><title>C</title><year>2022</year>
        <embedding>0.0 0.0 1.0 0.0</embedding></article>
    <article><title>NoEmbed</title><year>2023</year></article>
</articles>
```

Then `xmldb:reindex("/db/workshop-filter")`

---

### Task 4c: Keyword filter

```xquery
let $vec := [1.0, 0.0, 0.0, 0.0]
return
    collection("/db/workshop-filter")//article[
        ft:query-vector(., $vec, 3, map {
            "filter-query": "A"
        })
    ]/title/string()
```

Only articles matching "A" in full-text.

---

### Task 4d: Range filter

```xquery
ft:query-vector(., $vec, 3, map {
    "filter": map { "field": "year", "value": 2021 }
})
```

Requires `<field name="year" type="xs:integer">` in xconf.

---

### Task 4e: Facet drill-down

```xquery
ft:query-vector(., $vec, 3, map {
    "facets": map { "year": "2020" }
})
```

---

### Task 4f: Combined (AND)

```xquery
ft:query-vector(., $vec, 3, map {
    "filter-query": "A",
    "filter": map { "field": "year", "value": 2020 },
    "facets": map { "year": "2020" }
})
```

All three are AND-combined.

❓ What happens with filter-query "A" + year=2021?

---

### Task 5a: Check ONNX models

```xquery
xquery version "3.1";
import module namespace vector="http://exist-db.org/xquery/vector";

vector:models()
```

```xquery
(: 384-dim array :)
vector:embed("semantic search", "all-MiniLM-L6-v2")
```

Expected: `all-MiniLM-L6-v2` among models.

If empty: confirm image `duncdrum/existdb:experimental` and restart the container.

---

### Task 5b: Index-time embedding config

```xml
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
```

`vector-store="db"` + `embedding="local"` → ONNX at index time.

Store 4 documents (`Hello world`, `Machine learning`, `Quantum physics`, `Climate change`), each with just `<title>`. Vectors computed automatically during reindex.

---

### Task 5c: Semantic search

```xquery
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

---

### Task 5d: Try different queries

| Query | Expected top result |
|-------|-------------------|
| "global warming" | Climate change |
| "computer science" | Machine learning |
| "physics" | Quantum physics |

---

### Task 5e: Batch embedding

```xquery
let $batch := vector:embed-batch(
    ("Hello world", "Machine learning", "Quantum physics"),
    "all-MiniLM-L6-v2"
)
return (
    count($batch),         (: should be 3 :)
    array:size($batch(1))  (: should be 384 :)
)
```

---

### Task 6a: Reindex modes

```xquery
xmldb:reindex("/db/col", "all")       (: fulltext + vector :)
xmldb:reindex("/db/col", "fulltext")  (: text only :)
xmldb:reindex("/db/col", "vector")    (: vectors only :)
```

With `vector-store="db"`:
- `fulltext` → reads vectors from `vector.dbx`, no recompute
- `vector` → recomputes vector index only

---

### Task 6b: Setup lifecycle collection

Config uses `vector-store="db"`:

```xml
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
```

Store `doc1.xml` (First, `[1,0,0,0]`) and `doc2.xml` (Second, `[0,1,0,0]`), then reindex.

---

### Task 6c: Add doc + vector reindex

```xquery
xmldb:store("/db/workshop-lifecycle", "doc3.xml",
    <articles>
        <article><title>Third</title>
            <embedding>0.0 0.0 1.0 0.0</embedding></article>
    </articles>),

xmldb:reindex("/db/workshop-lifecycle", "vector")
```

Query `[0,0,1,0]` → "Third" should be top hit (exact match).

---

### Task 6d: Update doc + full reindex

```xquery
xmldb:store("/db/workshop-lifecycle", "doc1.xml",
    <articles>
        <article><title>First Updated</title>
            <embedding>0.0 0.0 0.0 1.0</embedding></article>
    </articles>),

xmldb:reindex("/db/workshop-lifecycle", "all")
```

Query `[0,0,0,1]` → "First Updated" should be top hit.

---

### Task 7a: Diagnostics

```xquery
xquery version "3.1";
import module namespace vector="http://exist-db.org/xquery/vector";

vector:diagnostics()
```

---

### Task 7b: Dimension mismatch

Config expects dim=4, data has `[1.0, 0.0, 0.0]` (3‑dim):

```
Vector hits: 1    (only "Good one" indexed)
Text hit: 1       ("Bad dim" still text-searchable)
```

Wrong dimension → **skipped**, not crashed. Text still works.

---

### Task 7c: Empty embedding

Article with no `<embedding>` element:

→ Skipped for vector search
→ Still text-searchable via `ft:query`

---

### Task 7d: Multi-doc ordering

Separate docs in separate files (a.xml, b.xml, c.xml):

```
Default order: A B C
Ordered by score: A B C
```

**Takeaway:** Default order is implementation-defined.
Always use `order by ft:score($hit) descending`.

---

### Recap

| What | How |
|------|-----|
| Config | `<vector-field>` in collection.xconf |
| KNN search | `ft:query-vector(., $vec, $k)` |
| Relevance | `order by ft:score($hit) descending` |
| Explicit field | `ft:query-field-vector("name", $vec, $k)` |
| Index-time embed | `embedding="local"` + `vector-store="db"` |
| Query-time embed | `vector:embed($text, $model)` |
| Filters | `filter-query`, `filter`, `facets` — AND |
| Scoped reindex | `"all"`, `"fulltext"`, `"vector"` |

**Next:** `workshop/solutions/` for full scripts.
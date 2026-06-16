## Task 4: Filters with Vector Search

**Objective:** Add range fields + facets and filter vector results.

### Step 1: Create collection with fields

```xquery
xquery version "3.1";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

xmldb:create-collection("/db/system/config/db", "workshop-filter"),
xmldb:create-collection("/db", "workshop-filter"),

xmldb:store("/db/system/config/db/workshop-filter", "collection.xconf",
    <collection xmlns="http://exist-db.org/collection-config/1.0">
        <index xmlns:xs="http://www.w3.org/2001/XMLSchema">
            <lucene>
                <text qname="article">
                    <field name="title" expression="title"/>
                    <field name="year" expression="year" type="xs:integer"/>
                    <facet dimension="year" expression="year"/>
                    <vector-field name="embedding"
                        expression="embedding"
                        dimension="4"
                        similarity="cosine"
                        encoding="text"/>
                </text>
            </lucene>
        </index>
    </collection>),

xmldb:store("/db/workshop-filter", "data.xml",
    <articles>
        <article><title>A</title><year>2020</year><embedding>1.0 0.0 0.0 0.0</embedding></article>
        <article><title>B</title><year>2021</year><embedding>0.9 0.1 0.0 0.0</embedding></article>
        <article><title>C</title><year>2022</year><embedding>0.0 0.0 1.0 0.0</embedding></article>
        <article><title>NoEmbed</title><year>2023</year></article>
    </articles>),

xmldb:reindex("/db/workshop-filter")
```

### Step 2: Keyword filter

```xquery
xquery version "3.1";

import module namespace ft="http://exist-db.org/xquery/lucene";

let $vec := [1.0, 0.0, 0.0, 0.0]
return
    collection("/db/workshop-filter")//article[
        ft:query-vector(., $vec, 3, map {
            "filter-query": "A"
        })
    ]/title/string()
```

Only articles that also match "A" in full-text should be returned.

### Step 3: Range filter

```xquery
xquery version "3.1";

import module namespace ft="http://exist-db.org/xquery/lucene";

let $vec := [1.0, 0.0, 0.0, 0.0]
return
    collection("/db/workshop-filter")//article[
        ft:query-vector(., $vec, 3, map {
            "filter": map { "field": "year", "value": 2021 }
        })
    ]/title/string()
```

### Step 4: Facet drill-down

```xquery
xquery version "3.1";

import module namespace ft="http://exist-db.org/xquery/lucene";

let $vec := [1.0, 0.0, 0.0, 0.0]
return
    collection("/db/workshop-filter")//article[
        ft:query-vector(., $vec, 3, map {
            "facets": map { "year": "2020" }
        })
    ]/title/string()
```

### Step 5: Combined filters (AND)

```xquery
xquery version "3.1";

import module namespace ft="http://exist-db.org/xquery/lucene";

let $vec := [1.0, 0.0, 0.0, 0.0]
return
    collection("/db/workshop-filter")//article[
        ft:query-vector(., $vec, 3, map {
            "filter-query": "A",
            "filter": map { "field": "year", "value": 2020 },
            "facets": map { "year": "2020" }
        })
    ]/title/string()
```

**Question:** What happens when you combine filters that don't overlap? (e.g., filter-query "A" + filter year=2021)

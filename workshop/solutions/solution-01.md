## Solution 1: Setup Collection with Vector Index

All steps combined in one script:

```xquery
xquery version "3.1";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

(: 1. Create collection hierarchy :)
xmldb:create-collection("/db/system", "config"),
xmldb:create-collection("/db/system/config", "db"),
xmldb:create-collection("/db/system/config/db", "workshop"),
xmldb:create-collection("/db", "workshop"),

(: 2. Store collection.xconf :)
xmldb:store("/db/system/config/db/workshop", "collection.xconf",
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
    </collection>),

(: 3. Store test data :)
xmldb:store("/db/workshop", "data.xml",
    <articles>
        <article><title>Alpha</title><embedding>1.0 0.0 0.0 0.0</embedding></article>
        <article><title>Beta</title><embedding>0.9 0.1 0.0 0.0</embedding></article>
        <article><title>Gamma</title><embedding>0.0 0.0 1.0 0.0</embedding></article>
        <article><title>Delta</title><embedding>0.0 0.0 0.0 1.0</embedding></article>
    </articles>),

(: 4. Reindex :)
xmldb:reindex("/db/workshop")
```

**Verify:**

```xquery
collection("/db/workshop")//title/string()
```

Returns: `Alpha Beta Gamma Delta`

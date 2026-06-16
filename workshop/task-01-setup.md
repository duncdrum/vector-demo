## Task 1: Setup Collection with Vector Index

**Objective:** Create a collection, configure a Lucene vector index, and store test data.

### Step 1: Create the workshop collection

Create `/db/workshop` in eXide:

```xquery
xquery version "3.1";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

xmldb:create-collection("/db", "workshop")
```

### Step 2: Store collection.xconf

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

Save the file in the collection. eXide automatically syncs it to the system config path (`/db/system/config/db/workshop`) — you do not need to store it there manually.

### Step 3: Store test data

In eXide, create `data.xml` in `/db/workshop`:

```xml
<articles>
    <article>
        <title>Alpha</title>
        <embedding>1.0 0.0 0.0 0.0</embedding>
    </article>
    <article>
        <title>Beta</title>
        <embedding>0.9 0.1 0.0 0.0</embedding>
    </article>
    <article>
        <title>Gamma</title>
        <embedding>0.0 0.0 1.0 0.0</embedding>
    </article>
    <article>
        <title>Delta</title>
        <embedding>0.0 0.0 0.0 1.0</embedding>
    </article>
</articles>
```

### Step 4: Reindex

```xquery
xquery version "3.1";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

xmldb:reindex("/db/workshop")
```

### Verify

```xquery
xquery version "3.1";

collection("/db/workshop")//title/string()
```

Should return: `Alpha Beta Gamma Delta`

# Vector Search Demo

EXPath application for eXist-db that demonstrates vector (semantic) search using Lucene and pre-computed embeddings.

## Features

- Natural language query → vector embedding → KNN search with `ft:query-vector`
- Results with similarity scores (`ft:score`)
- Optional keyword filter and facet support (see plan)
- Simple web UI: input box, search, results with title and score

## Build

```bash
ant package
```

Output: `build/vector-demo-1.0.0.xar`

## Run with Docker

```bash
ant package
docker build -t vector-demo:latest .
docker run -dit -p 8080:8080 --name vector-demo vector-demo:latest
```

App: http://localhost:8080/exist/apps/vector-demo/

After first run, reindex once to build the vector index:

```xquery
xmldb:reindex("/db/apps/vector-demo/data")
```

## Layout

- **Descriptors:** `expath-pkg.xml` (EXPath) and `repo.xml` (eXist-db deployment: target, prepare, finish).
- **Target collection:** `/db/apps/vector-demo` (set in `repo.xml`).
- **App files in repo root:** `controller.xql`, `index.html`, `search.xq`, `collection.xconf`, `data/articles.xml`.
- **Config:** `collection.xconf` for the data collection is installed under `/db/system/config/...` by `pre-install.xq`.

## License

LGPL-2.1-or-later

# Workshop: Semantic Search with eXist-db 7

**XML Prague 2026.06.04 eXist-db Users Meetup and Workshop**

- [Repository README](../README.md)
- [Live site](https://duncdrum.github.io/vector-demo/)
- [Slides](https://duncdrum.github.io/vector-demo/slides/)

**Prerequisites:** Docker, browser, `curl` (optional)

**Image:** `duncdrum/existdb:experimental`

```bash
docker run -d --name exist-semantic \
    -p 8080:8080 -p 8443:8443 \
    duncdrum/existdb:experimental
```

Open **eXide** at http://localhost:8080/exist/apps/eXide/index.html

## Tasks Overview

| # | Task | Est. time |
|---|------|-----------|
| 1 | [Set up a collection with vector index](task-01-setup.md) | 5 min |
| 2 | [Basic KNN search](task-02-basic-search.md) | 5 min |
| 3 | [Different similarity functions](task-03-similarity.md) | 5 min |
| 4 | [Filters and facets](task-04-filters.md) | 5 min |
| 5 | [Embedding and end-to-end search](task-05-embedding.md) | 10 min |
| 6 | [Reindex lifecycle](task-06-reindex.md) | 5 min |
| 7 | [Advanced edge cases](task-07-advanced.md) | 5 min |

Run each XQuery in eXide. Solutions in the [`solutions/`](solutions/) folder.

For Task 1, save `collection.xconf` and data files in the collection via eXide — eXide syncs config to the system path on save.

## Tips

- Use `xquery version "3.1";` at the top of every script
- Import modules: `import module namespace ft="http://exist-db.org/xquery/lucene";`
- Import vector: `import module namespace vector="http://exist-db.org/xquery/vector";`
- Check `vector:models()` to verify the image has model support
- Use `ft:score($hit) descending` for relevance ranking

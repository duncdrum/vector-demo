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
| 1 | Set up a collection with vector index | 5 min |
| 2 | Store data with pre-computed vectors | 5 min |
| 3 | Basic KNN search | 5 min |
| 4 | Different similarity functions | 5 min |
| 5 | Filters and facets | 5 min |
| 6 | Embedding and end-to-end search | 10 min |
| 7 | Reindex lifecycle | 5 min |

Run each XQuery in eXide. Solutions in the `solutions/` folder.

## Tips

- Use `xquery version "3.1";` at the top of every script
- Import modules: `import module namespace ft="http://exist-db.org/xquery/lucene";`
- Import vector: `import module namespace vector="http://exist-db.org/xquery/vector";`
- Check `vector:models()` to verify the image has model support
- Use `ft:score($hit) descending` for relevance ranking

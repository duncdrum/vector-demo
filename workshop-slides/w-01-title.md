## Workshop: Semantic Search with eXist-db 7

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
- Solutions in `workshop/solutions/`
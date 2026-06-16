## Solution 4: Filters

### Keyword filter

```xquery
collection("/db/workshop-filter")//article[
    ft:query-vector(., [1.0, 0.0, 0.0, 0.0], 3, map {
        "filter-query": "A"
    })
]/title/string()
```

Returns: `A` (only the article whose full-text matches "A")

### Range filter

```xquery
collection("/db/workshop-filter")//article[
    ft:query-vector(., [1.0, 0.0, 0.0, 0.0], 3, map {
        "filter": map { "field": "year", "value": 2021 }
    })
]/title/string()
```

Returns: `B` (year=2021)

### Facet drill-down

```xquery
collection("/db/workshop-filter")//article[
    ft:query-vector(., [1.0, 0.0, 0.0, 0.0], 3, map {
        "facets": map { "year": "2020" }
    })
]/title/string()
```

Returns: `A` (year facet = 2020)

### Combined (AND)

```xquery
collection("/db/workshop-filter")//article[
    ft:query-vector(., [1.0, 0.0, 0.0, 0.0], 3, map {
        "filter-query": "A",
        "filter": map { "field": "year", "value": 2020 },
        "facets": map { "year": "2020" }
    })
]/title/string()
```

Returns: `A` (satisfies all three conditions)

### No-match case

```xquery
collection("/db/workshop-filter")//article[
    ft:query-vector(., [1.0, 0.0, 0.0, 0.0], 3, map {
        "filter-query": "A",
        "filter": map { "field": "year", "value": 2021 }
    })
]/title/string()
```

Returns: (empty) — article "A" is year 2020, not 2021. No document satisfies both.

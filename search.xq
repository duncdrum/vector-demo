xquery version "3.1";

module namespace search = "http://exist-db.org/apps/vector-demo/search";

import module namespace ft = "http://exist-db.org/xquery/lucene";
import module namespace vector = "http://exist-db.org/xquery/vector";
import module namespace response = "http://exist-db.org/xquery/response";

declare variable $search:DATA_COLLECTION := "/db/apps/vector-demo/data";

(:~
 : Run vector search: embed $query then ft:query-vector (US-F3, US-Q1, US-Q4).
 : Optional: filter-query for keyword filter (US-Q2).
 :)
declare function search:run($query as xs:string) as item()* {
    let $vec := vector:embed($query, "all-MiniLM-L6-v2")
    let $k := 10
    let $hits := collection($search:DATA_COLLECTION)//article[ft:query-vector(., $vec, $k)]
    return
        search:json-results($hits)
};

(:~
 : Return results as JSON array: [{ "title": "...", "score": 0.9 }, ...].
 : Use fn:serialize with method=json, or build a string with escaped titles.
 :)
declare function search:json-results($hits as element(article)*) as xs:string {
    response:set-header("Content-Type", "application/json"),
    fn:serialize(
        array {
            for $a in $hits
            return map { "title": $a/title/string(), "score": ft:score($a) }
        },
        map { "method": "json" }
    )
};

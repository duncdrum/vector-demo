xquery version "3.1";

import module namespace xmldb = "http://exist-db.org/xquery/xmldb";

declare variable $home external;
declare variable $dir external;
declare variable $target external;

declare function local:mkcol-recursive($collection, $components) {
    if (exists($components)) then
        let $newColl := concat($collection, "/", $components[1])
        return (
            xmldb:create-collection($collection, $components[1]),
            local:mkcol-recursive($newColl, subsequence($components, 2))
        )
    else ()
};

declare function local:mkcol($collection, $path) {
    local:mkcol-recursive($collection, tokenize($path, "/"))
};

(: Ensure /db/system/config/db/apps/vector-demo/data exists and store collection.xconf there :)
local:mkcol("/db/system", "config"),
local:mkcol("/db/system/config", "db"),
local:mkcol("/db/system/config/db", "apps"),
local:mkcol("/db/system/config/db/apps", "vector-demo"),
local:mkcol("/db/system/config/db/apps/vector-demo", "data"),
xmldb:store-files-from-pattern("/db/system/config/db/apps/vector-demo/data", $dir, "collection.xconf")

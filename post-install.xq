xquery version "3.1";

import module namespace xmldb = "http://exist-db.org/xquery/xmldb";

declare variable $home external;
declare variable $dir external;
declare variable $target external;

xmldb:remove($target, "collection.xconf")

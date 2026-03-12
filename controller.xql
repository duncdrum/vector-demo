xquery version "3.1";

import module namespace request = "http://exist-db.org/xquery/request";
import module namespace response = "http://exist-db.org/xquery/response";
import module namespace util = "http://exist-db.org/xquery/util";

declare option exist:serialize "method=html media-type=text/html indent=no";

let $path := (request:get-attribute("exist.path"), "")[1]
return
    if ($path = "" or $path = "/" or $path = "/index.html") then
        doc(resolve-uri("index.html", request:get-attribute("exist.controller.path")))
    else if ($path = "/search") then
        let $query := request:get-parameter("q", "")
        return
            if ($query = "") then
                response:set-status-code(400),
                <error>Missing parameter: q</error>
            else
                (: Forward to search module; will return JSON or HTML :)
                util:import-module(xs:anyURI("http://exist-db.org/apps/vector-demo/search"), "search", xs:anyURI(resolve-uri("search.xq", request:get-attribute("exist.controller.path")))),
                search:run($query)
    else
        response:set-status-code(404),
        <not-found path="{$path}"/>

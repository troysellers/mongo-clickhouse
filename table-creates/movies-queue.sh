#!/bin/bash

avn service integration-update 60de67b3-5075-4177-90f3-d43d61ad4c8f \
    --project tsellers-demo \
    --user-config-json '{
    "tables": [
        {
            "name": "movies_queue",
            "columns": [
                {"name": "_id" , "type": "Nested(`$oid` String)"},
                {"name": "fullplot" , "type": "String"},
                {"name": "imdb" , "type": "Nested( rating Float32, votes Int64, id Int64)"},
                {"name": "year" , "type": "Int64"},
                {"name": "plot" , "type": "String"},
                {"name": "genres" , "type": "Array(String)"},
                {"name": "rated" , "type": "String"},
                {"name": "metacritic" , "type": "Int64"},
                {"name": "title" , "type": "String"},
                {"name": "lastupdate" , "type": "String"},
                {"name": "languages" , "type": "Array(String)"},
                {"name": "writers" , "type": "Array(String)"},
                {"name": "type" , "type": "String"},
                {"name" : "poster" , "type": "String"},
                {"name": "num_mflix_comments" , "type": "Int64"},
                {"name": "released" , "type": "Nested(`$date` Int64)"},
                {"name": "awards" , "type": "Nested(wins Int64, nominations Int64, text String)"},
                {"name": "countries" , "type": "Array(String)"},
                {"name": "cast" , "type": "Array(String)"},
                {"name": "directors" , "type": "Array(String)"},
                {"name": "runtime" , "type": "Int64"}
            ],
            "topics": [{"name": "sample_mflix.movies"}],
            "data_format": "JSONEachRow",
            "group_name": "movies_consumer2"
        }
    ]
}'

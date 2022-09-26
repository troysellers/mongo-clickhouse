
CREATE TABLE default.movies
(
    `_id` Nested(`$oid` String),
    fullplot String,
    imdb Nested(rating Float32, votes Int64, id Int64),
    year Int64,
    plot String,
    genres Array(String),
    rated String,
    metacritic Int64,
    title String,
    lastupdate String,
    languages Array(String),
    writers Array(String),
    `type` String,
    poster String,
    num_mflix_comments Int64,
    released Nested(`$date` Int64),
    awards Nested(wins Int64, nominations Int64, text String),
    countries Array(String),
    cast Array(String),
    directors Array(String),
    runtime Int64
) ENGINE = MergeTree ORDER BY (`_id.$oid`);

CREATE MATERIALIZED VIEW default.movies_mv TO default.movies AS 
SELECT *
FROM `service_mongo-demo--kafka`.movies_queue;
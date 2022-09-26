# mongo-to-aws-via-kafka

Terrafrom script to create the Aiven resources needed to source data from mongo atlas into an AWS S3 bucket

See

[Aiven for Apache Kafka](https://docs.aiven.io/docs/products/kafka.html)

[Aiven for Apach Kafka Connect](https://docs.aiven.io/docs/products/kafka/kafka-connect.html)

[Aiven S3 Sink config](https://docs.aiven.io/docs/products/kafka/kafka-connect/howto/s3-sink-connector-aiven.html)

[Mongo Source config](https://docs.aiven.io/docs/products/kafka/kafka-connect/howto/mongodb-poll-source-connector.html)

[Aiven terraform provider](https://docs.aiven.io/docs/tools/terraform.html)

There also exists a [simple golang client](https://github.com/troysellers/go-mongo-test) that reads movies from an IMDB list and attempts to insert or update into the sample movies dataset provided with the free trial Mongo Atlas service

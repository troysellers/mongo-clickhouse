resource "aiven_kafka" "demo-kafka" {
  project                 = var.project_name
  cloud_name              = var.cloud_name
  plan                    = "business-4"
  service_name            = join("-", [var.service_name_prefix, "kafka"])
  maintenance_window_dow  = "sunday"
  maintenance_window_time = "10:00:00"
  kafka_user_config {
    kafka_connect = true
    kafka_rest    = true
    kafka_version = "3.2"
    kafka {
      auto_create_topics_enable    = true
    }
  }
}

resource "aiven_kafka_connect" "demo-kafka-connect" {
  project = var.project_name
  cloud_name = var.cloud_name
  plan = "startup-4"
  service_name = "demo-kafka-connect"
  maintenance_window_dow = "sunday"
  maintenance_window_time = "10:00:00"
  depends_on = [aiven_kafka.demo-kafka]
  kafka_connect_user_config {
    kafka_connect {
      consumer_isolation_level = "read_committed"
    }

    public_access {
      kafka_connect = true
    }
  }
}

resource "aiven_service_integration" "demo-kafka-connect-integration" {
  project = var.project_name
  integration_type = "kafka_connect"
  source_service_name = aiven_kafka.demo-kafka.service_name
  destination_service_name = aiven_kafka_connect.demo-kafka-connect.service_name
  depends_on = [aiven_kafka_connect.demo-kafka-connect, aiven_kafka.demo-kafka]
}

resource "aiven_kafka_connector" "mongo-source" {
  project = var.project_name
  service_name = aiven_kafka_connect.demo-kafka-connect.service_name
  connector_name = "mongo-source"
  depends_on = [aiven_service_integration.demo-kafka-connect-integration]
  config = {
    "name" : "mongo-source",
    "connector.class" : "com.mongodb.kafka.connect.MongoSourceConnector",
    "connection.uri" :  var.mongo_uri,
    "database" : "sample_mflix",
    "collection" : "movies",
    "copy.existing" : "true",
    "poll.await.time.ms" : "1000",
    "publish.full.document.only" : true,
    "poll.max.batch.size" : 500,
    "output.format.value":"json",
    "output.format.key":"json",
    "key.converter.schemas.enable":"false",
    "value.converter.schemas.enable":"false",
    "key.converter":"org.apache.kafka.connect.storage.StringConverter",
    "value.converter":"org.apache.kafka.connect.storage.StringConverter"
  }
}

resource "aiven_clickhouse" "mongo-clickhouse" {
  project = var.project_name
  cloud_name = var.cloud_name
  plan = "hobbyist-beta"
  service_name = "mongo-demo-clickhouse"
  maintenance_window_dow = "sunday"
  maintenance_window_time = "10:00:00"
}

resource "local_file" "connect_to_clickhouse_script" {
  filename = "clickhouse-connect.sh"
  file_permission = 740
  depends_on = [aiven_clickhouse.mongo-clickhouse]
  content = <<-EOF
    #!/bin/bash
    clickhouse client \
      --host ${aiven_clickhouse.mongo-clickhouse.service_host} \
      --port ${aiven_clickhouse.mongo-clickhouse.service_port} \
      --user ${aiven_clickhouse.mongo-clickhouse.service_username} \
      --password=${aiven_clickhouse.mongo-clickhouse.service_password} \
      --secure
      EOF
}

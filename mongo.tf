data "aiven_service_component" "schema_registry" {
  project = var.project_name
  service_name = aiven_kafka.demo-kafka.service_name
  component = "schema_registry"
  route = "dynamic"
}

data "aiven_project" "demo-project" {
  project = var.project_name
}

data "aiven_project_vpc" "demo-vpc" {
  count = var.use_cloud_vpc ? 1 : 0
  project    = data.aiven_project.demo-project.project
  cloud_name = var.cloud_name
}

data "aiven_kafka_user" "kafka_admin" {
  project = var.project_name
  service_name = aiven_kafka.demo-kafka.service_name

  # default admin user that is automatically created each Aiven service
  username = "avnadmin"

  depends_on = [
    aiven_kafka.demo-kafka
  ]
}

locals {
  schema_registry_url = "https://${data.aiven_service_component.schema_registry.host}:${data.aiven_service_component.schema_registry.port}"
}

resource "aiven_kafka" "demo-kafka" {
  project                 = var.project_name
  cloud_name              = var.cloud_name
  plan                    = "business-4"
  project_vpc_id          = var.use_cloud_vpc ? data.aiven_project_vpc.demo-vpc[0].id : null
  service_name            = join("-", [var.service_name_prefix, "kafka"])
  maintenance_window_dow  = "sunday"
  maintenance_window_time = "10:00:00"
  kafka_user_config {
    schema_registry = true
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
  project_vpc_id = var.use_cloud_vpc ? data.aiven_project_vpc.demo-vpc[0].id : null
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
    "value.converter":"org.apache.kafka.connect.storage.StringConverter",
    "topic.suffix": "string"
  }
}

resource "aiven_kafka_connector" "mongo-source-json" {
  project = var.project_name
  service_name = aiven_kafka_connect.demo-kafka-connect.service_name
  connector_name = "mongo-source-json"
  depends_on = [aiven_service_integration.demo-kafka-connect-integration]
  config = {
    "_aiven.restart.on.failure": "true",
    "name" : "mongo-source-json",
    "connector.class" : "io.debezium.connector.mongodb.MongoDbConnector",
    "mongodb.hosts" : var.mongo_hosts,
    "mongodb.user" : var.mongo_user,
    "mongodb.password" : var.mongo_password,
    "database.include.list" : "sample_mflix",    
    "mongodb.name": "movies-stream",
    "key.converter": "org.apache.kafka.connect.json.JsonConverter",
    "key.converter.schemas.enable":"false",    
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable": "false",    
    "transforms": "unwrap",
    "transforms.unwrap.type": "io.debezium.connector.mongodb.transforms.ExtractNewDocumentState",
    "transforms.unwrap.flatten.struct": "true",
    "transforms.unwrap.sanitize.field.names": "true",
    "transforms.unwrap.drop.tombstones": "false",
    "transforms.unwrap.delete.handling.mode": "drop",
    "transforms.unwrap.operation.header": "true"
  }
}

resource "aiven_clickhouse" "mongo-clickhouse" {
  project = var.project_name
  cloud_name = var.cloud_name
  plan = "hobbyist-beta"
  project_vpc_id = var.use_cloud_vpc ? data.aiven_project_vpc.demo-vpc[0].id : null
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

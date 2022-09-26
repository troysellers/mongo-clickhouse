# Stream MongoDB Changes to Clickhouse

This project provides the resources necessary to setup a data stream of changes from the MongoDB sample dataset movies collection to an Aiven for Clickhouse service for analytics. 
Inspired by this handy blog post on [streaming IoT type data from Kafka to Clickhouse](https://aiven.io/blog/connecting-kafka-and-clickhouse)

When a user creates or updates a document in the source MongoDB service, this change will flow through a pipeline in Aiven and land in a Clickhouse table for analytics query. 

In effect, we are creating this 

![Pipeline](/img/mongo-clickhouse.png)



## Setup the Sample Mongo Dataset
This example uses the trial version of the Mongo Atlas DB cloud service. [Sign Up](https://www.mongodb.com/cloud/atlas/efficiency) and load the sample datasets. 

Once you have loaded you should see the movies data when you browse the collections. It is the movies collection we will be using for this. 

![Browse Collections](/img/mongo-sample-data.png)

# Create Aiven Resources
Now, let's create the resources that you will need for this project. 

Included in this repository is the terraform scripts you will need to create everything, so if you are familiar with [Terraform](https://registry.terraform.io/providers/aiven/aiven/latest/docs) and the [Aiven Terraform Provider](https://docs.aiven.io/docs/tools/terraform.html) please feel free to run these instead. 

At the moment, Aiven for Clickhouse is in a beta release which means there are a few things missing around the supporting tooling etc. 

Otherwise, if you would prefer to point and click let's 

## Aiven for Apache Kafka

Open the [Aiven Console](https://console.aiven.io) and either login or sign up to create your trial. Trials are awesome as they give you $300 worth of free credits for just this type of exploration. 
Once you are logged in you should see the empty service panel, go ahead and create your Kafka service by clicking the "New Service" button at the top right. 

![Empty Services](/img/empty-services.png)

For this demo I have setup using a Startup-2 plan in Google Cloud, Sydney Australia. As you are about to find out, changing this type of stuff with Aiven is super simple. 

Documentation for [Aiven for Apache Kafka](https://docs.aiven.io/docs/products/kafka.html)

![New kafka](/img/new-kafka-service.png)

## Aiven for Apache Kafka Connect
To setup Kafka Connect, we take a slightly different approach.  Open your newly created Kafka service by selecting it from the list of services and select the `Connectors` tab. 
From here you want to "Create new Apache Kafka Connect integration"

![Kafka Connect](img/kafka-connectors.png)

Once the modal opens, you want to create a New Service. I used a Startup-4 to keep the costs down!  

![New Kafka Connect](img/new-kafka-connect-service.png)

Documentation for [Aiven for Apache Kafka Connect](https://docs.aiven.io/docs/products/kafka/kafka-connect.html)

## Aiven for Clickhouse
Lastly, setup you Clickhouse service by starting at the (you guessed it!) "New Service" button again. For my service I used the single core Hobbyist-Beta plan so we aren't going to be getting that awesome multi-core performance that Clickhouse is so well know for. I'm sure you will agree that even this service is incredible for what we are doing her. 

Interestingly enough here there is nothing stopping you from creating your services in different regions, or even in different clouds as Aiven will handle all the networking requirements for you. An added bonus of this feature is that the price of data ingress / egress is also included in the price that you see on the screen. There is no metered data charges involved.

If you just clicked past the note about [Beta Services at Aiven](https://docs.aiven.io/docs/platform/concepts/beta_services), it is probably worth while to jump into the documentation and understand what this means.

![new clickhouse](img/new-clickhouse.png)

SURPRISE!! Extra credits for using the Beta Clickhouse service :) lucky you!

Documentation for [Aiven for Clickhouse](https://docs.aiven.io/docs/products/clickhouse.html)

# Configure Clickhouse
So now you have all 


[Aiven for Apache Kafka](https://docs.aiven.io/docs/products/kafka.html)

[Aiven for Apach Kafka Connect](https://docs.aiven.io/docs/products/kafka/kafka-connect.html)

[Aiven S3 Sink config](https://docs.aiven.io/docs/products/kafka/kafka-connect/howto/s3-sink-connector-aiven.html)

[Mongo Source config](https://docs.aiven.io/docs/products/kafka/kafka-connect/howto/mongodb-poll-source-connector.html)

[Aiven terraform provider](https://docs.aiven.io/docs/tools/terraform.html)

There also exists a [simple golang client](https://github.com/troysellers/go-mongo-test) that reads movies from an IMDB list and attempts to insert or update into the sample movies dataset provided with the free trial Mongo Atlas service

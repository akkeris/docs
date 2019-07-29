# ![ElasticSearch Logo](../assets/elasticsearch-small.png "ElasticSearch") ElasticSearch
 
## Features

Managed ElasticSearch plans for Akkeris have encrypted instances and a variety of CPU and memory systems. For high availability and high-load production environments the `premium-4` plan includes a 4 clustered instance of ElasticSearch.

## Plans

### Standard instances

|            | Standard-0  | Standard-1 | Standard-2   | Standard-3   |
|------------|-------------|------------|--------------|--------------|
| Price      | $50/mon     | $60/mon    | $150/mon     | $160/mon     |
| Storage    | 10GB        | 10GB       | 20GB         | 20GB         |
| Dedicated  | 1-Instance  | 1-Instance | 1-Instance   | 1-Instance   |
| Encrypted  | No          | Yes        | No           | Yes          |
| CPU Cores  | 1           | 1          | 2            | 2            |
| Memory     | 2GB         | 2GB        | 4GB          | 4GB          |

### Premium Instances

|            | Premium-0   | Premium-1   | Premium-2   | Premium-3   | Premium-4   |
|------------|-------------|-------------|-------------|-------------|-------------|
| Price      | $115/mon    | $125/mon    | $225/mon    | $325/mon    | $800/mon    |
| Storage    | 40GB        | 40GB        | 80GB        | 80GB        | 80GB        |
| Dedicated  | 1-Instance  | 1-Instance  | 1-Instance  | 1-Instance  | 4-Instances |
| Encrypted  | No          | Yes         | No          | Yes         | Yes         |
| CPU Cores  | 2           | 2           | 4           | 4           | 4           |
| Memory     | 8GB         | 8GB         | 16GB        | 16GB        | 16GB        |

## Provisioning 

```shell
aka addons:create akkeris-es:[standard-0|standard-1|standard-2|standard-3|premium-0|premium-1|premium-2|premium-3|premium-4] -a [app-space]
```

Once provisioned, the ElasticSearch https URL is added to the applications config vars as `ES_URL`. In addition the Kibana dashboard is included as the config var `KIBANA_URL`.

## Upgrading

ElasticSearch plans can be upgraded, while being upgraded however the existing addon in addition to the application are placed in maintenance mode during the upgrade process. In addition to upgrading, a plan can be downgraded so long as the existing disk space does not exceed the downgraded plan's disk space.
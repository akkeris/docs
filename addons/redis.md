# ![Redis Logo](../assets/redis-small.png "Redis")  Redis

<!-- toc -->

Reliable and powerful Redis as a service.

## Features

Managed redis plans for Akkeris provide reliable and fast redis caching.

## Plans

### Standard instances

Standard and hobby instances are great for sharing session information with small amounts of data among one to four applications.

|                  | Hobby-Dev   | Standard-0 | Standard-1   |
|------------------|-------------|------------|--------------|
| Price            | $15/mon     | $30/mon    | $50/mon      |
| Connection Limit | 20          | 100        | 250          |
| Dedicated        | 1-Instance  | 1-Instance | 1-Instance   |
| Encrypted        | No          | No         | No           |
| CPU Cores        | 1           | 1          | 2            |
| Memory           | 512MB       | 1536MB     | 3GB          |
| Shards           | 0           | 0          | 0            |

### Premium Instances

Premium instances are great for sessions with large amounts of data associated with each key and more than 4 apps that share the data. It's also great for key object storage for temporary data of large JSON objects.

|                  | Premium-0   | Premium-1   |
|------------------|-------------|-------------|
| Price            | $135/mon    | $270/mon    |
| Connection Limit | 500         | 1000        |
| Dedicated        | 2-Instances | 2-Instances |
| Encrypted        | No          | No          |
| CPU Cores        | 2           | 4           |
| Memory           | 12GB        | 16GB        |
| Shards           | 0           | 0           |

## Provisioning 

```shell
aka addons:create akkeris-redis:[hobby-dev|standard-0|standard-1||premium-0|premium-1] -a [app-space]
```

Once provisioned the redis hostname and port are added as the config var `REDIS_URL` in the format `redis://host:port`.

## Upgrading

Redis plans can be upgraded or downgraded on-demand. During the upgrade the redis instance and any attached applications will be placed in maintenace mode. 

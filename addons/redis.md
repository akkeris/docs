# ![Redis Logo](../assets/redis-small.png "Redis")  Redis

<!-- toc -->

Reliable and powerful Redis as a service.

## Features

Managed redis plans for Akkeris provide reliable and fast redis caching.

## Plans

### Standard instances

Standard and hobby instances are great for sharing session information with small amounts of data among one to four applications. Only standard-2 and standard-3 instances can store permenant persisted data.

|                  | Hobby-Dev   | Standard-0 | Standard-1   | Standard-2 | Standard-3   |
|------------------|-------------|------------|--------------|------------|--------------|
| Price            | $15/mon     | $30/mon    | $50/mon      | $35/mon    | $55/mon      |
| Connection Limit | 20          | 100        | 250          | 100        | 250          |
| Dedicated        | 1-Instance  | 1-Instance | 1-Instance   | 1-Instance | 1-Instance   |
| Encrypted        | No          | No         | No           | No         | No           |
| CPU Cores        | 1           | 1          | 2            | 1          | 2            |
| Memory           | 512MB       | 1536MB     | 3GB          | 1536MB     | 3GB          |
| Shards           | 0           | 0          | 0            | 0          | 0            |
| Persistent	   | No          | No         | No           | Yes        | Yes          |
| Backups          | None        | None       | None         | 7-Days     | 7-Days       |

### Premium Instances

Premium instances are great for sessions with large amounts of data associated with each key and more than 4 apps that share the data. It's also great for key object storage for temporary data of large JSON objects. Only premium-2 and premium-3 instances can store permenant persisted data.

|                  | Premium-0   | Premium-1   | Premium-0   | Premium-1   |
|------------------|-------------|-------------|-------------|-------------|
| Price            | $135/mon    | $270/mon    | $135/mon    | $270/mon    |
| Connection Limit | 500         | 1000        | 500         | 1000        |
| Dedicated        | 2-Instances | 2-Instances | 2-Instances | 2-Instances |
| Encrypted        | No          | No          | No          | No          |
| CPU Cores        | 2           | 4           | 2           | 4           |
| Memory           | 12GB        | 16GB        | 12GB        | 16GB        |
| Shards           | 0           | 0           | 0           | 0           |
| Persistent       | No          | No          | Yes         | Yes         |
| Backups          | None        | None        | 7-Days      | 7-Days      |

## Provisioning 

```shell
aka addons:create akkeris-redis:[hobby-dev|standard-0|standard-1||premium-0|premium-1] -a [app-space]
```

Once provisioned the redis hostname and port are added as the config var `REDIS_URL` in the format `redis://host:port`.

## Upgrading

Redis plans can be upgraded or downgraded on-demand. During the upgrade the redis instance and any attached applications will be placed in maintenace mode. 

## Using the Redis Plugin

The `redis` plugin allows users to perform advanced analysis and admninistration of redis instances. Before starting ensure you have the redis plugin installed by running:

```bash
aka plugins:install redis
```

This is not an exhaustive list of commands, but the popular ones, see `aka redis help` for more details.

**Listing Backups**

List available backups (amount depends on your plan). This feature is not available on all plans. If more than one redis is attached to the app specify the ADDON_ID as an argument.

```bash
aka redis:backups [ADDON_ID] -a app-space
```

**Creating a Backup**

Immediately capture a backup of a redis instance. If more than one redis is attached to the app specify the ADDON_ID as an argument.

```bash
aka redis:backups:capture [ADDON_ID] -a app-space
```

**Restoring a Backup**

Note: You can get the `BACKUP_ID` below from the `aka redis:backups` command. If more than one redis is attached to the app specify the ADDON_ID as an argument.

```bash
aka redis:backups:restore [ADDON_ID] BACKUP_ID -a app-space
```

**Getting Statistics**

If a redis instance is not behaving as expected or encountering performance issues pull usage statistics and information using the stats command. If more than one redis is attached to the app specify the ADDON_ID as an argument.

```bash
aka redis [ADDON_ID] -a app-space
```
# ![Memcached Logo](../assets/memcached-small.png "Memcached") Memcached

<!-- toc -->

Enterprise-Class Memcached for Developers

## Features

Managed memcached plans for Akkeris provide reliable and fast caching in memory-as-a-service.

## Plans

### Standard instances

Standard and hobby instances are great for development and tooling apps or production apps where only one app is using the cache or for shared session storage where the session values are small. Standard and hobby instances are not great for shared caches among multiple apps with large amounts of data stored for each key.

|                  | Hobby-Dev   | Standard-0 | Standard-1   |
|------------------|-------------|------------|--------------|
| Price            | $15/mon     | $30/mon    | $50/mon      |
| Connection Limit | 20          | 100        | 250          |
| Dedicated        | 1-Instance  | 1-Instance | 1-Instance   |
| Encrypted        | No          | No         | No           |
| CPU Cores        | 1           | 1          | 2            |
| Memory           | 512MB       | 1536MB     | 3GB          |

### Premium Instances

Premium instances are great for systems which have shared caches with large amounts of data across multiple apps.  Premium instances aren't great for shared session keys as its cost prohibitive, for these scenarios consider a standard instance instead.

|                  | Premium-0   | Premium-1   |
|------------------|-------------|-------------|
| Price            | $135/mon    | $270/mon    |
| Connection Limit | 500         | 1000        |
| Dedicated        | 2-Instances | 2-Instances |
| Encrypted        | No          | No          |
| CPU Cores        | 2           | 4           |
| Memory           | 12GB        | 16GB        |

## Provisioning 

```shell
aka addons:create akkeris-memcached:[hobby-dev|standard-0|standard-1||premium-0|premium-1] -a [app-space]
```

Once provisioned the memcached hostname and port are added as the config var `MEMCACHED_URL`.

## Upgrading

Memcached plans can be upgraded or downgraded on-demand. During the upgrade the memcached instance and any attached applications will be placed in maintenace mode. 

>**danger** Data is not retained while upgrading or downgrading (as memcached is a volatile storage!)

## Advanced Memcached with Memcached Plugin


To install the memcahed plugin use

```shell
aka plugins:install memcached
```

**Getting Statistics from Memcached Addons**

To get statistics on memcached usage run:

```shell
aka memcached -a [appname-space] [addonname]
┌───────────────────────┬───────────────┐
│ key                   │ value         │
├───────────────────────┼───────────────┤
│ pid                   │ 1             │
├───────────────────────┼───────────────┤
│ uptime                │ 22381642      │
├───────────────────────┼───────────────┤
│ time                  │ 1523365792    │
├───────────────────────┼───────────────┤
│ version               │ 1.4.24        │
├───────────────────────┼───────────────┤
│ libevent              │ 2.0.21-stable │
├───────────────────────┼───────────────┤
│ pointer_size          │ 64            │
├───────────────────────┼───────────────┤
│ rusage_user           │ 1238.060000   │
├───────────────────────┼───────────────┤
│ rusage_system         │ 1204.732000   │
├───────────────────────┼───────────────┤
│ curr_connections      │ 5             │
├───────────────────────┼───────────────┤
│ total_connections     │ 143721        │
├───────────────────────┼───────────────┤
│ connection_structures │ 8             │
├───────────────────────┼───────────────┤
│ reserved_fds          │ 10            │
├───────────────────────┼───────────────┤
│ cmd_get               │ 40524608      │
├───────────────────────┼───────────────┤
│ cmd_set               │ 809731        │
├───────────────────────┼───────────────┤
│ cmd_flush             │ 274           │
├───────────────────────┼───────────────┤
│ cmd_touch             │ 0             │
├───────────────────────┼───────────────┤
│ cmd_config_get        │ 1492091       │
├───────────────────────┼───────────────┤
│ cmd_config_set        │ 1             │
├───────────────────────┼───────────────┤
│ get_hits              │ 39750076      │
├───────────────────────┼───────────────┤
│ get_misses            │ 774532        │
├───────────────────────┼───────────────┤
│ delete_misses         │ 412           │
├───────────────────────┼───────────────┤
│ bytes_read            │ 4515632772    │
├───────────────────────┼───────────────┤
│ bytes_written         │ 159081631431  │
├───────────────────────┼───────────────┤
│ limit_maxbytes        │ 3356491776    │
├───────────────────────┼───────────────┤
│ accepting_conns       │ 1             │
├───────────────────────┼───────────────┤
│ listen_disabled_num   │ 0             │
├───────────────────────┼───────────────┤
│ threads               │ 2             │
├───────────────────────┼───────────────┤
│ conn_yields           │ 0             │
├───────────────────────┼───────────────┤
│ curr_config           │ 1             │
├───────────────────────┼───────────────┤
│ hash_power_level      │ 16            │
├───────────────────────┼───────────────┤
│ hash_bytes            │ 524288        │
├───────────────────────┼───────────────┤
│ bytes                 │ 692058        │
├───────────────────────┼───────────────┤
│ curr_items            │ 1520          │
├───────────────────────┼───────────────┤
│ total_items           │ 809731        │
├───────────────────────┼───────────────┤
│ expired_unfetched     │ 194806        │
├───────────────────────┼───────────────┤
│ reclaimed             │ 429990        │
└───────────────────────┴───────────────┘
```

**Flushing Cache**

```shell
aka memcached:flush -a [appname-space] [addon]
```

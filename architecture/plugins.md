# Plugins

Plugins provide a mechanism for extending functionality of the CLI.

## Memcached Plugin

To install the memcahed plugin use

```shell
aka plugins:install memcached
```

### Getting Statistics from Memcached Addons

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

### Flushing Cache

```shell
aka memcached:flush -a [appname-space] [addon]
```

## Certificate and TLS 

The certificate and TLS plugin allows you to purchase and use TLS/SSL certificates, to install it run:

```shell
aka plugins:install certs
```

>**info**
> This section is not yet complete, contribute to it to help our documentation efforts!

## Postgres Plugin 

The postgresql plugin allows users to create auditable read-only credentials, perform backups, pull logs and perform other maintenance tasks, to install it run:

```shell
aka plugins:install pg
```

>**info**
> This section is not yet complete, contribute to it to help our documentation efforts!

## Creating Plugins

See [Creating a Plugin](/extending-akkeris/creating-plugins.md) for more information on creating your own third-party plugins for Akkeris.

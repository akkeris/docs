# Plugins

Plugins provide a mechanism for extending functionality of the CLI.

## Memcached Plugin

The memcached plugina llows users to view cache statistics, flush caches in addition to restart memcached instances. 

```shell
aka plugins:install memcached
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

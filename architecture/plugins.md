# Using CLI Plugins

Plugins allow outside (third party or otherwise) developers to extend the functionality of the CLI including adding new commands or extending existing commands. See [Creating a Plugin](/extending-akkeris/creating-plugins.md) for more information on creating your own third-party plugins for Akkeris.

```shell
aka plugins                                            List public plugins
aka plugins:info NAME                                  Get more information on a plugin
aka plugins:publish NAME                               Publish a plugin
aka plugins:unpublish NAME                             Unpublish a plugin
aka plugins:revise NAME                                Update a published plugin
aka plugins:install NAME                               Install a plugin a new plugin
aka plugins:uninstall PLUGIN                           Uninstall a plugin
```

## Installing a Plugin

To install a plugin, you'll need to know either the repo of the plugin, or the name of the plugin (if it's published). 

```shell
aka plugins:install [REPO_OR_NAME]
```

For example,


```shell
aka plugins:install https://github.com/akkeris/cli-pg-plugin
```

Would install the postgres plugin from Akkeris' repo, you could also run:

```shell
aka plugins:install pg
```

Which would also install the same plugin using its published name.


## List Plugins

This allows you to browse plugins which have been published. 

```shell
aka plugins
:: pg
   Id: 8f2bd0cf-cdbe-4f92-a59f-57416f6de69b
   Repo: https://github.com/akkeris/cli-pg-plugin
   Description: A postgresql plugin to help manage alamo and appkit databases

:: securekey
   Id: b0d6a5ce-2cb2-4f3f-a5be-3a6fde4392a6
   Repo: https://github.com/akkeris/cli-securekey-plugin
   Description: Rotate secure keys from the command line
```

## Remove a Plugin

```shell
aka plugins:uninstall pg
```

## Publishing and Revising a Plugin

Once a plugin is created, publishing it is a great way to let other users discover it. 

```shell
aka plugins:publish mypluginname -d "Description of functionality, one sentence long." -r https://github.com/org/repo-of-cli-plugin -o "Your Name" -e "your@email.com"
```

To update the published plugin use the `revise` command.

```shell
aka plugins:revise mypluginname -d "Description of functionality, one sentence long." -o "Your Name" -e "your@email.com"
```

While the repo may be updatable via a revise command it will not change for users who have installed the plugin unless they uninstall and re-install it.

## Unpublishing a Plugin

To remove a published plugin from the registry, run `aka unpublish <name>`. This will not remove the plugin for any users who have installed it.

## Popular Plugins

### Memcached Plugin

The memcached plugina llows users to view cache statistics, flush caches in addition to restart memcached instances. 

```shell
aka plugins:install memcached
```

### Certificate and TLS 

The certificate and TLS plugin allows you to purchase and use TLS/SSL certificates, to install it run:

```shell
aka plugins:install certs
```

>**info**
> This section is not yet complete, contribute to it to help our documentation efforts!

### Postgres Plugin 

The postgresql plugin allows users to create auditable read-only credentials, perform backups, pull logs and perform other maintenance tasks, to install it run:

```shell
aka plugins:install pg
```

>**info**
> This section is not yet complete, contribute to it to help our documentation efforts!


# Maintenance Mode

<!-- toc -->

## Introduction

If you're deploying a large migration or need to disable access to your application for some length of time, you can use Akkeris' built in maintenance mode.  

When maintenance is turned on, a static maintenance page translated in multiple languages will be displayed to all visitors, without shutting down any of the existing dynos or addons (incase they are necessary to be running during the maintenace).

Visitors arriving to your app will be shown:

---

![Maintenance Page](/assets/maintenance.png)

---

## Usage

You can turn maintenance mode on or off using the CLI or [Platform Apps API](/architecture/apps-api/Apps.md).  To enable maintenance mode, run:

```shell
aka maintenance:on -a [appname-space]
```

To disable maintenance mode:

```shell
aka maintenance:off -a [appname-space]
```

At any point you may check whether maintenance mode is turned on or off by running:

```shell
aka maintenance -a [appname-space]
```

In addition, if you wish to completely shut down your application during this you can scale your applications dynos to zero by running:

```shell
aka ps:update -q 0 -a [appname-space]
```

> **info**
> If you scale down your dynos remember to scale them back up after taking your application out of maintenance mode.
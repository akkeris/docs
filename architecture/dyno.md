# Dynos, Dyno Types and Formations

Dynos, dyno types and formations can be somewhat abstract, but in short they define both what should be run, how it should be ran \(dyno types\), the collection of things to run \(formation\) and finally what is running \(dynos\).

### Dyno Types and Formations

All apps must have one or more "dyno types". A dyno type is a description of how to start an application \(including the start command, health checks, network ports to use, how many you'd like of this dyno type, and when to run it or on what schedule\). It's called a dyno and dyno type rather than a pod, container, servers or process to distinguish it from these as there are slight characteristics and aspects that make it different \(but similar\).

When Akkeris receives its first image \(after its first deploy\), it creates a "generic" web dyno type, that routes http traffic to a network port it automatically opens, and uses the start command specified in the Dockerfile, and finally uses the network port as a health check \(note the network port is provided as convention `$PORT` environment variable\).  It attempts to always keep one of these processes running for you.

While this may suit most users, via the command line, user interface or API's a user may request to change the "formation" of the application.  The formation of an application is the collection of dyno types and their definitions. A user may add a new dyno type, change the start command of an existing dyno type, or change the quantity of dynos running \(to scale the application\).

Every dyno type \(and dyno\) in an application receives the exact same configuration, environment, image and runtime. With only the execution context changing \(e.g., the startup command, when its executed, how to check its health, and what network ports are open\).

### Dynos

Akkeris executes applications by running the commands specified in your formation, on a dyno that's prepared and loaded with the slug \(or image\) and with all the config vars from addons or specified by the user.  Think of a dyno as a light weight virtualized unix container that contains your application running in its file system.

You have control over the formation that's running via the UI, CLI or [Platform Apps API](/architecture/apps-api/Formations.md) \(the `PATCH /apps/{app}/formation` end point\). You can start new dynos or change the amount running with the `aka ps:create` and `aka ps:update` command. For example, to change the quantity of web dynos that are automatically created on the first deployment, run:

```shell
aka ps:scale web=3 -a appname-space
```

When any portion of the definition of an application changes \(whether its the config vars, running image, formation or addons\) it triggers a new deployment of the application.  This is done through a rolling process of starting new dynos, checking the health of the dyno, then stopping the older dynos one at a time. This is called a rolling update, it is designed to prevent application downtime, if the new deployment causes the application to crash, or the health checks to fail, then the old version is not shutdown and continues to receive all traffic on all network ports.

You can see what dynos are running by executing via the CLI:

```shell
aka ps -a appname-space
```

Or by fetching the [Platform Apps API](/architecture/apps-api/Dynos.md) end point for dynos \(`GET /apps/{app}/dynos`\).


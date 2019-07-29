# How Akkeris Works

## Table of Contents

<!-- toc -->

## Introduction

This is a high-level, technical description of how Akkeris works. It tries to tie together many of the concepts you'll encounter in while creating and managing applications.  In addition it attempts to show some of the underpinning technologies behind it.

> Performing one or more of the Getting Started tutorials will make the concepts in this documentation more concrete.

Read this document sequentially, in order to tell a coherent story, it incrementally unvails and refines concepts describing the architecture and platform.  The final section ties together concepts from build, release and run phases of Akkeris.

## What is an application?

Traditionally in web development applications have been thought of us a single process running on a server.  While this is somewhat brief in its summation its more or less what Akkeris offers as well.

Akkeris expands the definition of an application \(or, an app\) to include a somewhat opinioned way of how that app manages its resources \(databases, etc\), its configuration, its relationship with other apps it needs in order to run, and finally how it starts, stops and scales.  These opinions help simplify devops efforts and increases the reliability of applications while standardizing specific parts of an application lifecycle.

More strictly speaking, an application is a collection of source code written in a language composed into an image \(or slug\) that can be combined with resources, configuration, environment, and a runtime.

While a slug \(or an image\) can be deployed via akkeris, a set of source code can also be built into an image by Akkeris, in addition Akkeris can watch and interact with source code management systems to ease this workflow and process.

### Defining what to run

An application is explicitly created and then may receive a set of source code to build, an existing image to deploy or a repository to watch for changes and subsequently build.   This information can sometimes be all that Akkeris may need to know to create and run an application.  To build from sources without watching a repository a URL with the source code \(in a ZIP or tar.gz format\) must be provided to it.

Applications can explicitly be created via the management UI, via the CLI \(`aka apps:create`\) or through an API end point on the [Platform Apps API](/architecture/apps-api.md) \(`POST /apps`\).

### Knowing how to build it

Once a set of sources are received for an application \(either from a source control system it's watching or from a zipped/tar.gz URL\), Akkeris inspects the source code for a file at the root \(e.g., very top level directory\) called a `Dockerfile.` A Dockerfile is an open source standard description of how to build and run an image.  You can learn more about docker files [here](https://docs.docker.com/engine/reference/builder/).  This file also provides a description of what the operating system should have installed, its dependent software and what system level characteristics the image will have to ensure a near bit-by-bit replication of the underlying operating system.

Builds can be created through the CLI \(`aka releases:create` and in previous Akkeris versions `aka builds:create`\) or through the API end point `POST /apps/{app}/builds`\) on the [Platform Apps API](/architecture/apps-api.md).

The generated slug \(or image, also known as a docker image\) is stored on a registry so that both Akkeris and users can inspect the exact bit-by-bit image running on systems.

### Knowing what to execute

As stated above, the `Dockerfile` describes not only how to build the application, but also provides a `CMD`or `ENTRYPOINT` that is then used to start the application. This is one way in which akkeris can receive instructions on how to start an application.  One difference between Akkeris and other platforms is it describes an application as a collection of processes, rather than one individual process.

Any one application may have one or more "dyno types". A dyno type is a description of how to start an application \(including the start command, health checks, network ports to use, how many you'd like of this dyno type, and when to run it or on what schedule\). It's called a dyno and dyno type rather than a pod, container, servers or process to distinguish it from these as there are slight characteristics and aspects that make it different \(but similar\).

When Akkeris receives its first image \(after its first deploy\), it creates a "generic" web dyno type to route http traffic to. It uses the `$PORT` environment variable to tell the application what network port to listen to for incoming http traffic, it uses the start command specified in the Dockerfile to determine what it should start, and finally uses the network port as a health check to ensure the web dyno is healthy.  It attempts to always keep one of these processes running for you.

While this may suite most users, via the command line, user interface or API's a user may request to change the "formation" of the application.  The formation of an application is the collection of dyno types and their definitions. A user may add a new dyno type, change the start command of an existing dyno type, or change the quantity of dynos running \(to scale the application\).

Every dyno type \(and dyno\) in an application receives the exact same configuration, environment, image and runtime. With only the execution context changing \(e.g., the startup command, when its executed, how to check its health, and what network ports are open\).

## Running Applications

Akkeris executes applications by running the commands specified in your formation, on a dyno that's prepared and loaded with the slug \(or image\) and with all the config vars from addons or specified by the user.  Think of a dyno as a light weight virtualized unix container that contains your application running in its file system.  The actual underlying mechanism that runs applications is [Docker](https://www.docker.com) and [Kubernetes](https://kubernetes.io), however the intent of Akkeris is to not necessarily bind itself to anyone backing technology, so that it may be replaced if necessary.

You have control over the formation that's running via the UI, CLI or [Platform Apps API](/architecture/apps-api.md) \(the `PATCH /apps/{app}/formation` end point\). You can start new dynos or change the amount running with the `aka ps:create` and `aka ps:update` command. For example, to change the quantity of web dynos that are automatically created on the first deployment, run:

```bash
aka ps:update -q 3 -a appname-space
```

When any portion of the definition of an application changes \(whether its the config vars, running image, formation or addons\) it triggers a new deployment of the application.  This is done through a rolling process of starting new dynos, checking the health of the dyno, then stopping the older dynos one at a time. This is called a rolling update, it is designed to prevent application downtime, if the new deployment causes the application to crash, or the health checks to fail, then the old version is not shutdown and continues to receive all traffic on all network ports.

You can see what dynos are running by executing via the CLI:

```bash
aka ps -a appname-space
=== web (constellation-prod): (from docker) (1)
 web.1380490387-gv2r3:	running 4/4/2018, 1:29:40 PM
 web.1380490387-nd1dd:	running 4/4/2018, 1:29:41 PM
 web.1380490387-x2395:	running 4/4/2018, 1:29:42 PM
```

Or by fetching the [Platform Apps API](/architecture/apps-api.md) end point for dynos \(`GET /apps/{app}/dynos`\).

### Providing Safe Spaces for Applications

Every dyno for each application runs in a space. Every application may only be in one space.  A space provides mechanisms for service discovery, sets specific types of compliance around how these spaces may conduct themselves and what additional protections or assurances should be provided.

#### Discovery Mechanisms

A space is logical grouping of applications that share the same local network or subnet. This allows applications to communicate between one another using ghost protocols based on ARP and other broadcast mechanisms.  In addition, applications may discover each other via config vars automatically added to their application dynos when they start.  Two config vars are added for each application in the same space, they contain the host and port for where the application may be contacted on its network http port. The config vars are named:

* `APPNAME_SERVICE_HOST`
* `APPNAME_SERVICE_PORT`

Where `APPNAME` is the name of the application \(without the space name\).

#### Compliance and Protections

Applications may require different assurances in their availability, or protections against how they can be changed for auditing and compliance purposes.  They may in addition require protections of how their network ports are accessible.  Compliances can be assigned to a space when its created with the CLI \(`aka spaces:create`\), UI or Platform Apps API \(`POST /spaces`\). Compliances \(by design\) cannot be modified once created.

The following compliances can be set:

* `socs` - When set this keeps audit logs that are sent to admins over email periodically.  Sensitive config vars are redacted within sub-systems as necessary to keep shared secrets safe.  In addition creating builds require a status check on both the source control repository, the app, and the pipeline\(s\) its in before applied.
* `prod` - This protection provides assurance of high availability, any space marked with this compliance will automatically be given preference if resources are limited. This will also forgive certain spikes in application resources.  Finally, production level shared credentials can only be attached to apps in prod spaces. This is a helpful fail safe to protect data and systems.
* `internal` - This protection keeps all network traffic and access to only the internal ingress as defined by network adminstrators.  Applications in spaces that are marked as internal will not be accessible publically.  This provides an additional level of protection to run applications that are only intended to be accessible by internal network users.

#### Logical Groupings

Finally spaces provide a way of grouping applications for a product + environment. All applications in a space will receive a domain name that conatins the space.  Generally, `[appname]-[spacename].[stack].yourdomain.io` or a slight varient of it. Applications can access each one another through these public or \(if internal compliance is set, private\) domain names through https.  The https end point for this domain is automatically routed to the web dyno type on the application through its network as http traffic \(Akkeris at the load balancer level handles encryption and TLS for the app\).  Note that public or private http end points are never provided to anything other than dynos running inside Akkeris.

### Defining pipelines and environments

While spaces are sometimes thought of as an equivelant to an environment \(e.g., development, QA, production\), they lack the definition of how code propogates through a system, and subsequently do not provide enough information for CI/CD systems to understand how deployments should be managed \(at least automatically and transparently\).

Akkeris defines a first class primitive called a `pipeline`,  a pipeline is a set of five distinct environments with special meanings for a few.  Not all five of the environments must be used, but some features of Akkeris depend on an app existing in a specific stage for the feature to fully be taken advantage of.  The stages are: `review`, `development`, `staging`, `canary`, and `production`.

One or more applications can be added to any stage, however each stage is a directed graph to the next stage and apps within one stage may be promoted to apps in the next stage.

Pipeline promotions are an important concept, they in affect are simply a deployment of the image within one stage to all the apps in the next stage.  This allows for apps which have passed a specific stage to have its exact image deployed to the next stage in the process.

Each pipeline may also contain extra checks or be configured to perform special duties upon promotion. For example a paranoid promote is a feature of Akkeris that prior to promotion will ensure that all the config vars that exist in the app being promtoed exist in all of the apps in the next stage, otherwise do not promote. The same checks are also done for addons.  Paranoid promotes can be enabled for any stage as a "status check".

Status checks happen during a promotion before the promotion happens.  All status checks must return a result of "ok" in order for a promotion to occur.  Any application or system can add itself as a status check and use this primitive and subsequently hooks to wire in CI/CD notificatoins and perform automated checks.  Once all systems report back "ok" a pipeline promotion occurs and the app is released.

### Previewing Apps `beta`

Finally, two of the stages have special meanings, `review` and `canary`.  Preview apps can be automatically created by enabling the feature on an app. If a pull request in the source repository is created that is destined for the branch that would normally cause a build on the `development` stage of the pipeline a new application forked from the development application is created and placed in the `review` stage.  Note that only the `web` dyno types are re-created with a quantity of 1, and any addons are attached unless they do not support sharing \(such as a log drain addon such as papertrail\).  The new preview app will contain the built image for the new code being reviewed, and if the pull request is reviewed the code is automatically updated on the preview app as well.

When the feature is enabled on a production application, any new release will trigger an entirely new app to be created with the same limitations applied to it as review apps \(only the web dyno, sharing its addons, etc\). This app is placed in the `canary` stage and a small portion of production traffic destined for the old version is routed to this new version prior to being fully released \(note this happens after all status checks have occured\). If the app begins experiencing a statistically larger amount of server or client error messages \(500/400 status codes\) the release is automatically aborted and the preview app is removed.

This helps ensure app deployments minimize their production impact on release.

## Storing and injecting configuration

An application’s configuration is everything that is likely to vary between environments \(staging, production, developer environments, etc.\). This includes backing services such as databases, credentials, or environment variables that provide some specific information to your application.

Akkeris lets you run your application with a customizable configuration - the configuration sits outside of your application code and can be changed independently of it.

The configuration for an application is stored in [config vars](/architecture/config-vars.md). For example, here’s how to configure an encryption key for an application:

```bash
aka config:set ENCRYPTION_KEY=my_secret_launch_codes -a appname-space
Adding config vars and restarting demoapp... done, v14
ENCRYPTION_KEY=my_secret_launch_codes
```

Config vars contain customizable configuration data that can be changed independently of your source code. The configuration is exposed to a running application via environment variables.

At runtime, all of the config vars are exposed as environment variables - so they can be easily extracted programatically. A node.js application deployed with the above config var can access it by calling`process.env["ENCRYPTION_KEY"]`.

All dynos in an application will have access to the exact same set of config vars at runtime.

Config vars can be set through the CLI \(`aka config:set`\), the UI or through the Platform Apps API \(`PATCH /apps/{app}/config-vars`\). Note that any change to a config var will create a new deployment.

## Managing Resources

Applications typically make use of [addons](/architecture/addons.md) to provide backing services such as databases, queueing & caching systems, storage, email services and more. Add-ons are provided as services by that may be managed by anyone \(e.g., it could be an external service that's managed by a vendor such as AWS or an internal services managed by a team member\).

Akkeris treats these add-ons as attached resources: provisioning an add-on is a matter of choosing one from the list of addon services and plans, and creating it.  In addition addons may be attached if they already exist on another application and can be shared.

For example, here's how to add an Akkeris Redis to an application:

```bash
aka addons:create alamo-redis:small -a appname-space
```

Dynos do not share file state, and so add-ons that provide some kind of storage are typically used as a means of communication between dynos in an application. For example, Redis or RabbitMQ could be used as the backing mechanism in a queue; then dynos of the web process type can push job requests onto the queue, and dynos of the queue process type can pull jobs requests from the queue.

The add-on service provider is responsible for the service - and the interface to your application is often provided through a config var. In this example, a`REDIS_URL`will be automatically added to your application when you provision the add-on. You can write code that connects to the service through the URL, for example:

```ruby
uri = URI.parse(ENV["REDIS_URL"])
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
```

Add-ons are associated with an application, much like config vars - and so the earlier definition of a release needs to be refined. A release of your applications is not just your slug and config vars; it’s your slug, config vars as well as the set of provisioned add-ons.

## Metrics and Logs

Akkeris treats logs as streams of time-stamped events, and collates the stream of logs produced from all of the processes running in all dynos, build logs, and the Akkeris platform components, into the logshuttle a high-performance, real-time system for log delivery.

It’s easy to examine the logs across all the platform components and dynos:

```bash
aka logs -t -a appname-space
2018-03-24T01:07:18Z appname-space akkeris/router: host=appname-space.stack.domain.io fwd=1.1.1.1 method=GET path=/theme request_id=24FB1BE9-D54C-4BF8-AE0C-DCAEC5CD2BE1 status=200 service=1077 connect=10 total=1089 bytes=448 
2018-03-24T01:07:20Z appname-space app[web.1562910588-cg82f]: Entering api.getTheme for user 339910
2018-03-24T01:07:20Z appname-space app[web.1562910588-ccefa]: Entering api.getTheme for user 991031
```

Here you see 3 timestamped log entries, the first from Akkeris' http router, the last two from two dynos running the web process type.  Notice that `web.XXXXXXXXXX-xxxxx` the format describes three things, the first "web" describes which dyno type output the logs, the next 10 X's \(`1562910588`\) are an identifier that's the same across all dyno types for a deployment, when a new deployment happens this number will change.  The last five x's indicate the individual dyno running, in this case it allows you to see if one dyno is exhibiting problems from another.

The logshuttle is an important concept in that it collects logs from any systems associated with your app \(including builds, platform, dyno, database, redis, and others\) and aggregates them into one stream you can view or forward to other destinations.

Logshuttle keeps a limited buffer of log entries solely for performance reasons. To store them for future use, use log drains. Log drains are a feature of the log shuttle and allow you to forward all logs to a syslog end point over `UDP`, `TCP`, `TLS+TCP` or `HTTPS`.

Akkeris will also emit into your logs an average of your memory and CPU utilization \(roughly every 15 minutes\).  For more detailed metrics the UI, CLI \(`aka metrics`\) and Platform Apps API provide a mechanism for pulling down to a 1 second average of memory, filesystem I/O and CPU usage.

## Getting Users to Apps

Depending on your formation information and dyno types, you may have a `web` dyno running and may want users to be able to go to a website where a path on that site ties back to the `web` process running.

Dyno types named web are different than other process types - they will receive HTTP traffic through a network port. Akkeris' sites and routes distribute incoming requests in a round robin fashion across your running web dynos \(if more than one\).

So scaling your application to handle web traffic becomes fairly trivial:

```bash
aka ps:scale web=5 -a appname-space
```

This would scale the app appname-space to five dynos accepting web requests that evenly have requests distributed across them.  This however does impose one limitation, sticky sessions cannot be used as incoming requests cannot be directed on the same dyno for each session.  To overcome this use a backing redis, memcahced or postgres system to enable each dyno to handle any request it receives.

Note that requests to any site will always be https, as Akkeris only supports public or private websites that are https and not http, however Akkeris will manage terminating the TLS encryption for you and forward back a non-encrypted http request to your application.  Your applications http end point is never exposed anywhere except to internal infrastructure of Akkeris.

Web dyno types can listen to incoming http traffic by attaching their listener to the network port defined by the environment variable \(e.g., config var\) `$PORT`.

### Creating a website

Often its necessary for multiple different apps with different responsibilities to exist under one domain for security, and simplicity reasons.  Akkeris supports the ability to create any website and dedicate traffic on a specific path \(and its subpaths\) to go to a specific app, while other apps receive traffic on a different path. This is called HTTP reverse proxying, or HTTP routing.

A default site is created for each application when its created allowing that application to be immediately reachable, however an application can exist in more than one site.  Creating a site is as easy as:

```bash
aka sites:create www.siteyouwant.com
```

Note that if a TLS certificate does not exist yet it, it will automatically be requested through the certs system. The domain record is automatically created as well. If domain has not been purchased, it must be manually purchased and added to Akkeris \(this must be manually done by administrators\).  If the domain name is not managed by Akkeris it must be manually pointed to Akkeris' http router.

## Going Global

Each application may be placed within a specific region.  Any site or application must exist in the same region. While apps can be managed from one interface a region does impose some geographic limitations; all applications in a space must be in the same region, all applications in the same site must be in the same region, and finally addons are only available in specific regions, and a addon in a specific region may only be shared with other apps in the same region.

Regions provide boundaries for ensuring performance of applications is maintained, and that regionally considerations such as where data physically lies is clearer, in addition sites must take into consideration how they will geographically distribute themselves with different domains.

While regions impose limitations other workloads and tooling may operate across regions.  For example, applications that exist in multiple regions in different spaces can be added to the same stage of a pipeline.  The status checks within a pipeline are executed for every application within that pipeline \(and consequenctially for every region\).  This allows engineers to deploy immediately to multiple regions seemlessly to an unlimited set of destinations, with the same checks, tests and assurances \(within each region\) you'd have when deploying to one region and one site.

### Tying it all together

The concepts explained here can be though of as those related to creating, building and launching an application \(or site\), and those that involve the runtime maintenance and operation of applications \(or sites\).

From creating an application, to creating a site, to launching applications Akkeris provides first-class automated mechanisms for building, scaling and maintaining applications in a globalized way.


# Recovering Offline Applications

<!-- toc -->

## Introduction

Your application may be experiencing downtime for a number of reasons. This article will help you discover why and what you can do to remedy the problem.

## Check your application logs

The first step is to check your [application logs](/architecture/log-drains.md). Many common application errors as well as Akkeris errors are printed to your application logs. To view your logs, run:

```shell
aka logs -t -a [appname-space]
```

Note if your application has crashed, it may be in a "crash back-off loop", akkeris will eventually attempt another restart, be patient as previous logs are not shown, only new logs coming in, so you may need to wait for the next attempt to start the app.

If your logs show one or more Akkeris error codes, you should investigate the cause of this issue.  Our [description of errors](/support/akkeris-error-codes.md) is the best place to start.

## Check your app

You may check on the current status of an application (and its processes) by running:

```shell
aka ps -a [appname-space]
```

This will tell you the current state of each dyno type (and each dyno within the dyno type). Ensure you are running hte right number of each process type (and at least one), adn that the dynos are not in a crashing state (and that they have the correct start up command). 

If your dyno's are crashing, you can attempt to restart the app with:

```shell
aka ps:restart -a [appname-space]
```

It may be useful to keep a tail of the logs running while you restart it to ensure you see the logs coming in on the app.

## Check your apps health

If you've assigned an application health check try checking it first to ensure it returns between 200-399 http status code.  You can do this by running a curl command:

```shell
curl -v https://yourapp.com/health
```

Note: this assumes you've set an http health check on your application to the URL `/health`, if you haven't explicitly done this, you can skip this step.

If the curl command returns back a status code outside of 200-399 you may need to inspect your logs for further errors.

## Ensure it has enough memory

If your application is attempt to request more memory than its allowed it may fail to start or run correctly.  You can check your logs for `R14` errors, if you find your application is experiencing memory limit problems you can adjust the size of dyno using `aka ps:update -s [size] [type] -a [appname-space]`.  You can also find a list of available memory sizes with `aka ps:sizes`. 

Note, if you're using Java you may wish to read [R14 - Out of Memory and Java](/support/r14-out-of-memory-and-java.md) as your application may suffer from a common Java issue causing it to accidently consume more memory than it has available.

## Ask for help

If you are still unable to determine why your application is down, get in touch with us via our slack channel.
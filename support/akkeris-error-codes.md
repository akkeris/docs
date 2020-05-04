# Akkeris Error Codes

<!-- toc -->

## Introduction

Akkeris error codes are alerts that there was a problem or situation that caused your application to stop responding or to stop function propertly.  This may in most cases cause your application to restart. During an error one or more of the following error codes are emitted into [logs](/architecture/log-drains.md) and will fire the `crashed` [webhook](/architecture/webhooks.md).

Whenever your app experiences an error on your web dyno type, Akkeris will not deliver an http response, but hang up on the client making the request. 

## H0 - Unknown Error

This occurs when an unknown error causes an application to crash but the issue cannot be isolated to the application, platform or one of the external components related.  In this event see the logs for more information on the cause. 

```
2018-04-09T16:21:58Z app-space akkeris/error: H0 - An unknown error occured
```

## H8 - Premature Exit

A premature exit occures when a dyno exits with an exit code of 0.  This indicates a succesful exit, which is unexpected for most dyno types.  This may or may not be cause for concern unless the dyno was expected to continue to run.  Thus, this is termed a premature exit as the application believes it was supposed to exit, while the platform expected it to continue to run.


```
2018-04-09T16:21:58Z app-space app[web.2453604099-0lcnh]/error: H8 - An unknown error occured
```


## H9 - App did not startup

This occures when a dyno could not be started because the start command failed to execute. Check the start command of the app (either in `aka ps` or in the `Dockerfile`), and that the command is executable (e.g., the file has a executable bit set).  Usually this is due to typo in the `Dockerfile` or a shell script being executed where the script does not have a `+x` bit set.


```
2018-04-09T16:21:58Z app-space app[web.2453604099-0lcnh]/error: H9 - Application failed to start
```


## H10 - App crashed

The application exited with an error code that was above zero.  This indicates an unexpected problem with the application, check the logs for more information.


```
2018-04-09T16:21:58Z app-space app[web.2453604099-0lcnh]: Unable to find environment variable DATABASE_URL!
2018-04-09T16:21:58Z app-space app[web.2453604099-0lcnh]/error: H10 - Application Crashed
```

## H20 - App boot timeout

The application failed to begin listening to the specified network port and answer http requests, or the http health check on the application returned below a 200 or above 399 status code.  This will only occur on the web dyno type.  Your application should be listening to the environment variable `$PORT` and should be processing http requests on it (only for the web dyno type however).  If the application does not need web dyno type, scale the web dynos to zero (`aka ps:update -q 0 web -a app-space`)


```
2018-04-09T16:21:58Z app-space app[web.2453604099-0lcnh]/error: H20 - App boot timeout
```

## H99 - Platform error

This occures when the platform encoutnered an error and due to the infrastructure issues the application was terminated.  This may occur when an underlying server component experiences an issue and causes the applications network or file system to fail.


```
2018-04-09T16:21:58Z app-space app[web.2453604099-0lcnh]/error: H99 - Platform error, many many apologies.
```


## R14 - Memory quota exceeded

A dyno requires memory in excess of its quota. If this error occurs, the dyno will page to swap space to continue running, which may cause degraded process performance. If swap is unavailable the application will begin to exhibit unpredictable behavior or out of memory errors. The R14 error is calculated by total memory swap, rss and cache.  This may cause an application failure, a warning (as an R15 error) is emitted first.


```
2018-04-09T16:21:58Z app-space app[web.2453604099-0lcnh]/error: R14 - Application is out of memory and exceeded its quota.
```


## R15 - Memory quota critical

A dyno requires more memory and is quickly approaching its memory limit. If this occurs, the dyno will page to swap space and will continue to run. If the memory quota continues in this critical state an R14 error will be emitted and the dyno may crash or exhibit unpredictable behaviour. An R15 is emitted as a warning.

```
2018-04-09T16:21:58Z app-space app[web.2453604099-0lcnh]/error: R15 - Error R15 (Memory limit critical) 350MB/256MB
```





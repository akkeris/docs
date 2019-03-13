# Logs and Log Drains

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

### Outputting Logs

To output logs simply write to standard out or standard err \(stdout, stderr\) file descriptors and any information written will be streamed to the destination log drain or through a log session and our API's.  Consult your language or frameworks documentation on how to write out logs to stdout/stderr.  Do not write logs to a file on the file system. These files will be inaccessible and unretrievable, in addition they will be completely lost when the app restarts as the file system is not persistent or retained.

### Listening to Logs

You can listen to logs coming off of the log stream through the Platform Apps API \(POST /apps/{app}/log-sessions\), the UI or through the CLI \(`aka logs -t -a appname-space`\).  The log shuttle or session does not retain existing logs and can only stream new logs.  If no logs are flowing through your app it may appear as if this feature is not working when it is.

### Adding a Log Drain

A log drain can be added to an application using `aka drains:create` via the CLI or from the [Platform Apps API](/architecture/apps-api.md) \(`POST /apps/{app}/log-drains`\).  A log drain should be formatted as a URL where the following schemas are supported:

* https

* syslog://
* syslog+tcp://
* syslog+udp://
* syslog+tls://

Note that UDP log drains are discouraged as they may not reliably deliver logs as others \(also syslog:// schema is an alias for syslog+tcp\).  Using an https log drain end point will also cause buffering in its delivery and may chunk responses causing stuttering in your log streaming \(which may or may not be an issue for some needs\). 

Log drains does not support custom token systems at this time.






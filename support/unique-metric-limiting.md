# Unique Metric Limits

On occasion, you may notice a message in your logs similar to the following:

`[web.akkeris/metrics]: Unique metrics limit exceeded. Metric discarded: [count] myMetric1234`

This means that your application is creating too many unique metrics. It is important to note that as the total number of unique metrics increases, the performance of the underlying database sharply declines. This not only affects your app, but every Akkeris app in the cluster.

Any new unique metric created after the limit has been reached will be dropped. Entries for existing metrics will still be added to the database. 

To avoid this issue in the future, avoid creating metrics with high amounts of variance in the name or tag (for example, request IDs, log file names, timestamps, etc).

To remove existing metrics, please contact your friendly neighborhood Akkeris administrators.

(For more information on high cardinality with time series databases, you can visit https://blog.timescale.com/blog/what-is-high-cardinality-how-do-time-series-databases-influxdb-timescaledb-compare/)
# ![PostgreSQL Logo](../assets/postgres-small.png "PostgreSQL") PostgreSQL

## Features

All postgresql plans are maintained and backed up automatically for you. In addition, database minor patches are done during maintenance windows. There are two primary types of postgres database to choose from, cloud `akkeris-postgresql` or on premises `akkeris-postgresqlonprem`.  On premises databases should be used if there are compliance concerns such as the database stores sensitive information such as personality identfiable information or data that for legal reasons must remain at a specific location.

## Cloud Plans

The postgres plans are spread across different tiers: hobby, standard and premium. To choose a plan you may
want to consider the following:

1. How much planned downtime is acceptable? Hobby instances may have up to 4 hours a month, which may be acceptable, even in production depending on your workload.
3. How complex are the queries in your app? If its typical join, orders of a few tables, a lower plan hobby or standard (0 or 1) would be fine. For reporitng purposes where aggregation and complex sub-queries are needed you may want to consider a high memory system such as a premium-1.
3. What storage requirements do you have? Applications with large amounts of data should consider picking a standard (1 or 2) plan.
4. Does your data have compliance requirements (e.g., does it contain PII)? If your application has special compliance needs see the on-premises plans.


|            | Hobby       | Std-0 | Std-1   | Std-2   | Prem-0 | Prem-1 | Prem-2 |
|------------|-------------|------------|--------------|--------------|-----------|-----------|-----------|
| Price      | $0/mon    | $5/mon   | $15/mon    | $45/mon    | $60/mon | $135/mon | $720/mon |
| Storage    | 512MB       | 4GB        | 16GB         | 32GB         | 20GB      | 50GB      | 100GB     |
| RAM        | 1GB         | 2GB        | 2GB          | 4GB          | 4GB       | 8GB       | 16GB      |
| High Avail | No   | No         | Yes          | Yes          | No        | No        | Yes       |
| Burstable  | No          | No         | Yes          | Yes          | No        | No        | No        |
| Dedicated  | No          | No         | No           | No           | Yes       | Yes       | Yes       |
| Direct SQL | Yes         | Yes        | Yes          | Yes          | Yes       | Yes       | Yes       |
| Extensions | No          | No         | No | No | Yes       | Yes       | Yes       |
| Data Clips | Yes         | Yes        | Yes          | Yes          | Yes       | Yes       | Yes       |
| Row Limit  | 1mill       | None       | None         | None         | None      | None      | None      |
| Conn. Lim  | 20   | 120        | 120          | 480          | 120       | 120       | 500       |
| Rollback   | None        | 1 Day      | 4 Days       | 4 Days       | 1 Day     | 4 Days    | 4 Days    |
| Encrypted  | No          | No         | Yes          | Yes          | No        | No        | Yes       |


### Provisioning a Cloud Database

```bash
aka addons:create akkeris-postgresql:[hobby|standard-0|standard-1|standard-2|premium-0|premium-1|premium-2] -a [app-space]
```


### Cloud Hobby Tier

The hobby tier runs on a shared-tenant server with a dedicated database. It does not permit adding new databases or adding new extensions. In addition, it does not support more than twenty connections a time.  The hobby tier is great for systems like blogs and tooling apps (such as a header dump) and light-weight apps.

## On Premesis Plans

On premises plans are placed on a clustered shared tenant server with a dedicated database. It does not permit adding new databases or adding new extensions. The on-premises plans are bustable in CPU and memory usage but have a hard limit of 2GB.  

### Provisioning an On-Premsis Database

```bash
aka addons:create akkeris-postgresqlonprem:shared -a [app-space]
```

## Upgrading

If your app's requirements eventually outgrow the resources provided by the initial plan you select, you can upgrade your database as well (note, this may result in a small amount of downtime).


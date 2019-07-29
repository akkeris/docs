# ![PostgreSQL Logo](../assets/postgres-small.png "PostgreSQL") PostgreSQL

## Features

All postgresql plans are maintained and backed up automatically, to provision a new postgresql instace use the service `akkeris-postgresql`. The postgres plans are spread across different tiers: hobby, standard and premium. To choose a plan you may
want to consider the following:

1. How much planned downtime is acceptable? Hobby instances may have up to 4 hours a month, which may be acceptable, even in production depending on your workload.
3. How complex are the queries in your app? If its typical join, orders of a few tables, a lower plan hobby or standard (0 or 1) would be fine. For reporitng purposes where aggregation and complex sub-queries are needed you may want to consider a high memory system such as a premium-1.
3. What storage requirements do you have? Applications with large amounts of data should consider picking a standard (1 or 2) plan.
4. Does your data have compliance requirements (e.g., does it contain PII)? If your application has special compliance needs see the on-premises plans.

## Plans

### Standard &amp; Hobby Instances

The hobby tier is great for systems like blogs and tooling apps (such as a header dump) and light-weight apps. Standard tier is great for some smaller production applications and development systems. Hobby databases are not encrypted, however all standard instances are both are highly available and burstable. You should not use hobby or standard instances if you require creating extensions, access as a postgres super user or the ability to create read replicas, and access database logs.

|                    | Hobby       | Standard-0 | Standard-1   | Standard-2   |
|--------------------|-------------|------------|--------------|--------------|
| Price              | $0/mon      | $5/mon     | $15/mon      | $45/mon      |
| Storage            | 512MB       | 4GB        | 16GB         | 32GB         |
| RAM                | 1GB         | 2GB        | 2GB          | 4GB          |
| High Availablity   | No          | No         | Yes          | Yes          |
| Burstable          | No          | No         | Yes          | Yes          |
| Dedicated          | No          | No         | No           | No           |
| Direct SQL         | Yes         | Yes        | Yes          | Yes          |
| Extensions         | No          | No         | No           | No           |
| Data Clips         | Yes         | Yes        | Yes          | Yes          |
| Row Limit          | 1mill       | None       | None         | None         |
| Connection Limit   | 20          | 120        | 120          | 480          |
| Rollback           | None        | 1 Day      | 4 Days       | 4 Days       |
| Encrypted          | No          | No         | Yes          | Yes          |



### Premium Instances

Premium instances are dedicated postgres servers, they provide superuser access in addition to more control over the database. Premium instances are great for production apps that require extensions or super user database access. They're also great for systems that consistently use a high amount of database CPU and I/O. Premium instances include the ability to restart the database, fetch logs, create extensions and create read replicas. While premium's are always dedicated instances, premium instances are not burstable (unlike standard instances). 

|                    | Premium-0 | Premium-1 | Premium-2 |
|--------------------|-----------|-----------|-----------|
| Price              | $60/mon   | $135/mon  | $720/mon  |
| Storage            | 20GB      | 50GB      | 100GB     |
| RAM                | 4GB       | 8GB       | 16GB      |
| High Availability  | No        | No        | Yes       |
| Burstable          | No        | No        | No        |
| Dedicated          | Yes       | Yes       | Yes       |
| Direct SQL         | Yes       | Yes       | Yes       |
| Extensions         | Yes       | Yes       | Yes       |
| Data Clips         | Yes       | Yes       | Yes       |
| Row Limit          | None      | None      | None      |
| Connnection Limit  | 120       | 120       | 5000      |
| Rollback           | 1 Day     | 4 Days    | 4 Days    |
| Encrypted          | Yes       | Yes       | Yes       |


### Postgres V9, V10 and V11

Different postgres database engine versions are available with plans that have the version as a suffix, such as `-v11` or `-v9` depending on the current default version.

## Provisioning 

```shell
aka addons:create akkeris-postgresql:[hobby|standard-0|standard-1|standard-2|premium-0|premium-1|premium-2] -a [app-space]
```

Once provisioned, the postgres database url in the format of `postgres://user:pass@host.com:5432/dbname` is added as the config var `DATABASE_URL` to the app.

## Upgrading

If your app's requirements eventually outgrow the resources provided by the initial plan you select, you can upgrade your database as well (note, this may result in a small amount of downtime). To upgrade your database retrieve the ID of the addon from `aka addons -a [app-space]`.  Then run the upgrade with the new plan as the option `aka addons:upgrade -a [app-space] a3bf4f1b-2b0b-822c-d15d-6c15b0f00a08 akkeris-postgresql:premium-0`.  If the addon `a3bf4f1b-2b0b-822c-d15d-6c15b0f00a08` in the example before was a standard-0 it would be upgraded to a dedicated premium-0.

Apps are placed into maintence mode while the applications database is upgraded.

In addition to upgrading you can downgrade a plan using `aka addons:downgrade`, note if their is insufficient space to downgrade your plan the operation will fail and revert back to the existing plan.


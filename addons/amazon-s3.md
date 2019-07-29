# ![Amazon S3 Logo](../assets/s3-small.png "Amazon S3") Amazon S3

## Features

Amazon S3 buckets provide a object storage system that can hold large (to nearly unlimited) amount of data. S3 buckets can be versioned so that the history of changes and copies of old resources are kept and accessible if needed, all 'Versioned' plans are capable of this. S3 buckets can also be encrypted, all 'shield' plans automatically encrypt the underlying S3 hardware storage with KMS keys. 

## Plans

|            | Basic       | Shield     | Versioned    | Versioned + Shield  |
|------------|-------------|------------|--------------|---------------------|
| Price      | $50/mon     | $60/mon    | $150/mon     | $160/mon            |
| Storage    | 500GB       | 500GB      | 2TB          | 2TB                 |
| Dedicated  | Yes         | Yes        | Yes          | Yes                 |
| Rollback   | None        | None       | History      | History             |
| Encrypted  | No          | Yes        | No           | Yes                 |
| Geo-Repl.  | No          | No         | No           | No                  |
| Versioned  | No          | No         | Yes          | Yes                 |

## Provisioning 

```shell
aka addons:create akkeris-postgresql:[basic|shield|versioned|shield-versioned] -a [app-space]
```

Once provisioned, the config vars `S3_ACCESS_KEY`, `S3_BUCKET`, `S3_LOCATION`, `S3_REGION`, and `S3_SECRET_KEY` are added to application.

## Upgrading

S3 cannot be automatically upgraded once created, resources in the S3 should be synced down to a file system then syncronized up to a newly created S3 with the target settings.

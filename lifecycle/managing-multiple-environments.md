# Managing Environments

<!-- toc -->

## Introduction

Akkeris has a multi-facet concept of a typical environment such as `dev`, `qa` or `prod`.  To understand the concept of an environment you must understand [spaces](/architecture/spaces.md), the [compliances](/architecture/spaces.md) of the space, and [pipeline stages](/architecture/pipelines.md).

Environments are seperated distinct runtimes, spaces, applications (with seperated addons) and sites that cooperatively produce a product or function.  You may have multiple environments so that you may test new code without breaking a product, site or app for users. 

In addition, you may have more than two environments.  One in which you write your code and review it with other engineers, another where its independently tested, then finally a third that end-users inteact with.  This is not uncommon as development may have features in progress that typically are not yet ready for full integration testing.

Unfortunately this concept of environments begins to break down as changes to one environment (whether content, data size, configuration or code) begin to drift too far from another (Think Windows vs Macs). This drift may cause code that runs well in your testing environment to fail in your production environment.

In addition, the concept begins to fail as some environments may require access to sensitive data such as personality identifiable information, password hashes and credit cards of users.

## Managing Drift

The solution is to have your environments match as much as possible. This can be acheived through pipelining and spaces. 

Pipelining allows the exact bit-by-bit image of code running in your dev, testing and production environments to be promoted up a workflow chain.  This workflow chain or pipeline, can also check values such as config vars and addons to ensure that if you have a config var set in stage, that you have a similar value in your production environment prior to promoting. 

Spaces allow multiple applications to be grouped together it also provides standard mechanisms such as service discovery environment variables to allow for inter-space communication.  This eases the burden of information an application must carry in its configuration.  Spaces also provide a conceptual boundary that one can immediately compare the running applications, configuration and addons for all of the dependencies of an envrionment to another environment in one place.  This allows you to more easily diagnose issues in one environment vs. another. 

## Managing Compliance

Spaces contain a compliance tag that allows them to protect information in its addons (such as databases) and shared secrets set in config vars. Using the `socs` compliance tag information such as passwords, keys and tokens are redacted from all users to only permit access through auditable mechanisms. 

For instance, a database password may be visible through a config var to an application, but not be available when you run `aka config -a [appname-space]`.  Akkeris will automatically replace sensitive information in `socs` spaces with the value `[redacted]` if it sees it.

Note that the intent of this compliance is not to prevent users from accessing their own data, but to create an audit log of what users have done to a database or system, while still allowing applications to function without performance degradation of a system-wide audit log.  For most addons users may still create unique credentials that will create audit logs upon connecting and disconnecting. 

For instance, on postgresql databases the postgres plugin will allow you to generate a unique credential that you may use to connect to the database by running:

```bash
aka pg:credentials:create -a [appname-space]
```

See an addons plugin information to see how you can generate these credentials.

Finally, spaces provide special protections with the `prod` tag.  This tag will ensure that the application (and its addons) cannot be accidently removed by any users.
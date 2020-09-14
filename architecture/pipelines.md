# Pipelines

<!-- toc -->

## Introduction

A pipeline is a group of apps that share the same codebase. Each app in a pipeline represents one of the following steps in a continuous delivery workflow:

* Review
* Development
* Staging
* Production

A common Akkeris continuous delivery workflow has the following steps:

1. A branch is created in a repository and pull request is made.
2. Akkeris creates apreview app for the pull request, allowing developers to review the change.
3. When the change is ready, it’s merged.
4. The master or central branch automatically deploys to the apps in the development stage.
5. When it’s ready, the application is promoted to staging apps, and then production.

## Maintaining Environments

Regardless if you maintain an environment thats named differently than the pipeline stages, Akkeris can still help with CI/CD tasks and managing environments. Any set of applications (one or more) can be placed into any stage, and during a promotion the image from the previous stage is pushed to all apps downstream. 

If for example you have a `dev`, `qa`, `stage`, and `prod` environment, you can seperately add your `dev` app to the `development` environment and the `qa` and `stage` apps to the `staging` pipeline step.  When the `dev` app is promoted its bit-by-bit image (seperate from its configuration or resources) is moved forward to both the `qa` and `stage` apps as they are both in the `staging` step. 

## Simplifying CI/CD

Once you’ve defined a pipeline, you and your team no longer have to worry about building and releasing outside of the apps in your `development` environment. Instead, `aka pipelines:promote` will copy your app’s build artifact (i.e. slug) to the downstream app(s) as a new release. In addition pipelines allow for additional functionality such as preview apps and automated CI/CD.

In addition the pipeline workflow tool can be quite useful when managing multiple region deploys.  Consider if you had tweleve different regions your production app may run in. All twelve apps can be simultaneously deployed to with a promotion of a `stage` app to `prod` by adding all twelve apps to the `production` step.

## Creating a pipeline

For example say we have `myapp-space-dev` and `myapp-space-qa` we could create a new pipeline using:

```shell
 $ aka pipelines:create myapp
```

### Adding apps to a pipeline

Then we can add both apps to the pipeline

```shell
aka pipelines:add myapp -a myapp-space-dev -s development
app                                  id=d3dd5715-66a8-435b-b5a5-2252a56b6c8e, name=myapp-space-dev
id                                   c21b5e30-ef20-4685-b472-4c59fcce086e
created_at                           2017-05-16T18:52:03.467Z
updated_at                           2017-05-16T18:52:03.467Z
stage                                development
pipeline                             id=13a3e3c3-a375-4623-bc6c-2a1405910733, name=myapp
```
```shell
aka pipelines:add myapp -a myapp-space-qa -s staging
app                                  id=d3dd5715-66a8-435b-b5a5-2252a56b6c8e, name=myapp-space-qa
id                                   c21b5e30-ef20-4685-b472-4c59fcce086e
created_at                           2017-05-16T18:52:03.467Z
updated_at                           2017-05-16T18:52:03.467Z
stage                                development
pipeline                             id=13a3e3c3-a375-4623-bc6c-2a1405910733, name=myapp
```
```shell
aka pipelines:add myapp -a myapp-space-stg -s staging
app                                  id=d3dd5715-66a8-435b-b5a5-2252a56b6c83, name=myapp-space-stg
id                                   c21b5e30-ef20-4685-b472-4c59fcce0863
created_at                           2017-05-16T18:52:03.467Z
updated_at                           2017-05-16T18:52:03.467Z
stage                                development
pipeline                             id=13a3e3c3-a375-4623-bc6c-2a1405910733, name=myapp
```

### Promoting an app

Now that we have both apps in our pipeline we can promote the code on myapp-space-dev to myapp-space-qa and myapp-space-stg.

```shell
aka pipelines:promote -a myapp-space-dev
Promoting app ⬢ myapp-space-dev ...  ✓ 

 = myapp pipeline (development -> staging)

Promoted: ⬢ myapp-space-dev (Release: e06899ed-48c3-456e-b2e9-2536e1ae4973)
      To: ⬢ myapp-space-qa 
	  ⬢ myapp-space-stg 
```

We can now see the release on the `myapp-space-qa` of the build from `myapp-space-dev`, note that `myapp-space-dev` and `myapp-space-qa` retain completely separate config vars and environments (which are not promoted or changed).

```shell
aka releases -a myapp-space-qa
• v1 (13616620-2cc5-4a61-851b-819c01734dad) - current
  Build: d4128fa1-ac32-4ae5-ba25-c16dd7415184
  Created: 2017-05-16T18:56:45.359Z
  Status: succeeded
  Description: Promotion from myapp-space-dev
```


## Advanced Pipelines

Multiple apps can be at any one stage in a pipeline, the first app found will be promoted, however when promoting you may specify a specific app to promote and the release id on that app to promote (in addition to explicitly specifying a target app).  This allows you to establish more complicated workflows/pipelines.

A simple staging to production pipeline:

```
myapp-staging ---> myapp
```

Or, a team’s more complex pipeline:

```
myapp-jim-dev ---
                  \
                    ---> myapp-staging ---> myapp
                  /
myapp-kim-dev ---
```

### Pipeline Status Checks `beta`

Pipeline status checks allow a third party system to report a state of `pending`, `success`, `failure` or `error` about a release through the [Platform Apps API](/architecture/apps-api/Release-Statuses.md). The third party systems check can then be required to be successful before any release is allowed to be promoted to any pipeline stage. A status check can be reported on any release, to create a new status check see the [Release Statuses](/architecture/apps-api/Release-Statuses.md) section of the Apps API.  

#### Adding Required Status Checks

Specific stages of a pipeline can require that one or more release statuses on a release are in the `success` state to allow the release to be promoted. To add required statuses to a pipeline and stage while adding an app to a pipeline stage run:

```bash
aka pipelines:add -a [appname-space] -c my-status-check -c my-other-check -s staging`
```
#### Updating Required Status Checks

To update an existing pipeline, use `aka pipelines:info [PIPELINE_NAME]` to get the pipeline coupling id to update, then run:

```bash
aka pipelines:update PIPELINE_COUPLING_UUID -c my/status-check
```

#### Removing Required Status Checks


To remove pipeline status checks, run the update command without any `-c` option and all status checks will be removed. Removing status checks does require elevated access privileges.

```bash
aka pipelines:update PIPELINE_COUPLING_UUID
```

#### Viewing Required Status Checks

To view the pipeline status checks added to couplings, run:

```bash
aka pipelines:info PIPELINE_NAME

 ᱿ staging
  Id: eda4a600-fa5b-4595-b378-93733a6a231c
  App: appa-default (f004d613-86a5-413b-86da-405526e098ec)
  Status Checks: 

 ᱿ staging
  Id: 8e754b16-c1c5-4861-bf85-f6bbd5180206
  App: appb-default (9879a6f8-a7d5-42de-8154-a6cea1824b00)
  Status Checks: 

 ᱿ production
  Id: 08f4d458-a492-44c0-9a78-667d8b24644d
  App: appc-default (60f53f16-e70b-4214-bb50-790b0c7d441c)
  Status Checks: my-status-check, my-other-check
```

The name of a status check (e.g., `my-status-check`) is typically referred to as a "context". 

To get a list of status checks available for a pipeline, run:

```bash
aka pipelines:checks PIPELINE_NAME
```




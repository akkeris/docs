# Building Services & Addons


## Introduction

Add-ons allow apps to have config vars unique to that application (and service) to be injected into its environment when it runs. This provides a core element to extending Akkeris. Addon services (or services for short) must be unique by region. 

All addon services contain a list of plans that can be "provisioned", this is exposed on an API end point from the service, along with various meta data helping the user make decisions on which plan is right for them. Each plan has an associated cost with it, Akkeris automatically keeps track of who requested what resources and at what price. 

Once a plan is provisioned to an application on each deployment the service receives a request for any config vars that should be added to the application, the values returned are injected into the environment of the application. Note that each release will result in the config vars being fetched again (as they are not cached or stored anywhere else other than the target service).

## Installing New Addon Services

>**danger** Danger Zone: This requires administrative privileges in Akkeris to install new addon services.

Each region (via the Akkeris region-api deployment) contains a list of services from its `SERVICES` environment variable. The `SERVICES` environment variable contains a comma delimited list URLS for all of the addon services. Adding the http/https URL to your addon service to this list will expose it as an offering to users in akkeris for that region (note this may take 10-15 mintues for caches to reset and become available). 

To support multiple regions, simply add multiple services (or the same service) to all region-apis. For more information about administrating regions and the region-api see the Akkeris administrator guide or contact your Akkeris administrator to install your addon service.

## Programming New Addon Services 

All addon services must adhere to (at least) the [Open Service Broker API Specification v2.13](https://github.com/openservicebrokerapi/servicebroker/blob/v2.13/spec.md). There are various clients, libraries and services that help implement the specification that can be used. For an example of an addon service see the [Akkeris Database Broker](https://github.com/akkeris/database-broker). Basic authentication can be used to check credentials for incoming requests.

Akkeris will make standard OSB requests to `/v2/catalog` to retrieve a list of plans (and service information). In addition, `/v2/service_instances/` will be called. Note that asyncronous provisioning is not only support but preferred, syncronous provisioning is discouraged as it provides a poor user experience for end users as the call to completely provision must succeed before the UI or CLI (or the Apps API) can complete (thus causing the UX to stop temporarily). 

The `last_operation` is called to retrieve the status of the addon until its available (interval polling is done every 30 seconds with a timeout after 25 minutes). This requires that all provisioned resources become availble in 25 minutes otherwise the addon is orphaned (from Akkeris' perspective it does not exist anymore).

During a release cycle the credentials returned from the get bindings call will be injected as environment variables. Note that when an addon is attached to an app (including the owning application) the create bindings call is made. These calls will only occur after the `last_operation` end point has returned successfully. 

### Unsupported OSB Features

Some features are not supported on OSB brokers, while not supported, does not necessarily mean Akkeris does not fully support the OSB spec. 

* Passing parameters on creation. OSB Brokers are not allowed to have parameters passed, this is intentional as we ask that all addon service creators have healthy "safe" defaults for their services and plans that can be modified. Doing this simplifies the addon creation process and makes it vastly easier for us to support features such as Preview Apps, One Click Apps and manifests. Configuration of services can also be done post-provision using actions or through standard upgrade/downgrade mechanisms with different plans. For instance, the postgres engine in the database broker is not passed in as an option but rather part of the plans we offer (`premium-0-v9` vs `premium-0-v10`). This simplifies or flattens the choices for end users.

* Volume service, route service type OSB bindings. Only `credential` bindings and `log drain` bindings are supported via OSB brokers. This is intentional as volume services (e.g., file systems) are practices we'd like to discourage in Akkeris due to their opaque nature (see [Best Practices and Guidelines](/best-practices-and-guidelines.md) for more information). In addition route services are not supported as all applications are only allowed to service https requests through sites or their apps ingress, this helps us enforce security boundaries and tracebility in the network. 

### Additional Meta Data

Akkeris supports additional metadata for plans and services that you can take advantage of to provide better experiences while users are browsing addon services. This allows you to provide logos, and additional structured information on how your addon works, see the database broker implementation for more infromation: https://github.com/akkeris/database-broker/blob/master/pkg/broker/storage.go#L374.

## Plan Recommendations

**DO**

1. Provide more plans than you intend to initial expect people to use.  Since addons are not pre-provisioned you might as well give users options.
2. For shared tenant systems still give different various quotas (even if they are not enforced) to give users expectations of what resources they are guaranteed. If the actual resources ends up being larger than expected treat it as "burstable" or "elastic".
3. Name plans based on use cases (such as hobby, dev, production).  If there's multi-dimensions or two primary factors to an addon consider using the nomenclature `standard-X`, `premium-X` or `shield-X` as these are commonly used across Akkeris.
4. Use pricing models rather than strict cost pass-through with addon pricing.  For instance, on databases creating a read replica may considerably increase the cost of a database, however Akkeris does not support post-humorously changing the price of an addon service because a user created a read replica. When creating an addon service such as this either A) build the cost of the possibility of a replica into the overal cost, or B) create a plan that includes a read replica that includes the cost and read replica up front.

**DONT**

1. For shared tenant systems avoid naming a plan as "shared". This does not give users any expectations of what they will recieve, nor does it tell them what they are guaranteed to have. It's better to simply state what you intend to guarantee the user in a plan (even if they end up recieving more) than to not guarantee the user any resources and state that is "shared".
2. Use t-shirt sizes such as `small`, `medium` and `large`. Focusing uses to intentionally think about the plans by giving them more nuanced names is preferred.











# Summary

--
## Getting Started

  * [Installing](/getting-started/prerequisites-and-installing.md)
  * [By Language](/getting-started/languages.md)
    * [Node.js](/getting-started/nodejs.md)
    * [Java](/getting-started/java.md)
    * [Go](/getting-started/go.md)
    * [Ruby](/getting-started/ruby.md)
    * [Scala](/getting-started/scala.md)
    * [Other Languages](/getting-started/other-languages.md)

----
## Documentation

* [How Akkeris Works](/how-akkeris-works.md)
  * [What Defines an Application](how-akkeris-works.md#introduction)
  * [How Applications Build](/how-akkeris-works.md#knowing-how-to-build-it)
  * [How Applications Run](/how-akkeris-works.md#running-applications)
  * [How Addons Work](/how-akkeris-works.md#managing-resources)
  * [How Sites Work](/how-akkeris-works.md#getting-users-to-apps)
* [Extending Akkeris](/how-to-extend-akkeris.md)
  * [About Webhooks](/architecture/webhooks.md)
  * [Third Party Integrations](/architecture/webhooks.md#integrations)
  * [Creating Plugins](/extending-akkeris/creating-plugins.md)
  * [Creating One-Click Apps](/one-click/creating.md)
  * [Learning The Akkeris Apps API](/extending-akkeris/akkeris-apps-api-tutorial.md)
  * [Creating Addon-Services](/extending-akkeris/building-addons.md)
  * [Creating Release Statuses](/architecture/apps-api/apps-api.md#release-statuses)
* [Networking &amp; Websites](/networking-and-websites/networking-and-websites.md)
  * [Creating a Website](/architecture/sites-and-routes.md)
  * [HTTP Filters](/architecture/filters.md)
  * [HTTP/2 Support](/networking-and-websites/http2.md)
* [Application Lifecycle](/lifecycle/application.md)
  * [Releases](/architecture/releases.md)
  * [Preview Apps](/architecture/preview-apps.md)
  * [Pipelines](/architecture/pipelines.md)
  * [Special Config Vars](/architecture/config-vars.md#injected-runtime-config-vars)
  * [Managing Environments](/lifecycle/managing-multiple-environments.md)
  * [Maintenance Mode](/lifecycle/maintenance-mode.md)
* [Troubleshooting &amp; Support](/support/support.md)
  * [Akkeris Error Codes](/support/akkeris-error-codes.md)
    * [R14 - Out of Memory and Java](/support/r14-out-of-memory-and-java.md)
  * [Unresponse Applications](/support/offline-applications.md)
  * [URL Parsing](/support/url-parsing.md)
  * [Unique Metric Limits](/support/unique-metric-limiting.md)
* [TaaS](/taas/taas.md)
  * [Test Registration](/taas/registering-tests.md)
  * [Promoting Apps with TaaS](/taas/promoting-apps-with-taas.md)
  * [Tutorial - Testing Akkeris Apps](/taas/testing-akkeris-apps-with-taas.md)
  * [Tutorial - Pipeline Status Checks](/taas/pipeline-status-checks-with-taas.md)

---
## Concepts

* [Addons](architecture/addons.md)
* [Config Vars](architecture/config-vars.md)
* [Dyno](/architecture/dyno.md)
* [Filters](/architecture/filters.md) `beta`
* [Log Drains](architecture/log-drains.md)
* [Releases](/architecture/releases.md)
* [Sites and Routes](/architecture/sites-and-routes.md)
* [Spaces](/architecture/spaces.md)
* [Pipelines](/architecture/pipelines.md)
* [Plugins](/architecture/plugins.md)
* [Webhooks](/architecture/webhooks.md)
* [One-Click Apps](/one-click/apps.md)

----
## Reference

* [Apps API](/architecture/apps-api/apps-api.md)]
  * [Apps](/architecture/apps-api/Apps.md)
  * [App Setups](/architecture/apps-api/App-Setups.md)
  * [Audits](/architecture/apps-api/Audits.md)
  * [Authentication](/architecture/apps-api/Authentication.md)
  * [Builds](/architecture/apps-api/Builds.md)
  * [Config](/architecture/apps-api/Config.md)
  * [Dynos](/architecture/apps-api/Dynos.md)
  * [Features](/architecture/apps-api/Features.md)
  * [Filters](/architecture/apps-api/Filters.md)
  * [Formations](/architecture/apps-api/Formations.md)
  * [Invoices](/architecture/apps-api/Invoices.md)
  * [Log-Drains](/architecture/apps-api/Log-Drains.md)
  * [Log-Sessions](/architecture/apps-api/Log-Sessions.md)
  * [Organizations](/architecture/apps-api/Organizations.md)
  * [Pipelines](/architecture/apps-api/Pipelines.md)
  * [Plugins](/architecture/apps-api/Plugins.md)
  * [Regions](/architecture/apps-api/Regions.md)
  * [Releases](/architecture/apps-api/Releases.md)
  * [Release Statuses](/architecture/apps-api/Release-Statuses.md)
  * [Routes](/architecture/apps-api/Routes.md)
  * [Services, Addons, & Attachments](/architecture/apps-api/Services-Addons-Attachments.md)
  * [Sites](/architecture/apps-api/Sites.md)
  * [Source Control Hooks](/architecture/apps-api/Source-Control-Hooks.md)
  * [Spaces](/architecture/apps-api/Spaces.md)
  * [SSL & TLS Certificates](/architecture/apps-api/SSL-TLS-Certificates.md)
  * [Stacks](/architecture/apps-api/Stacks.md)
  * [Webhooks](/architecture/apps-api/Webhooks.md)
  * [Webhook Event Payloads](/architecture/apps-api/Webhook-Event-Payloads.md)

---
## Addons

* [Amazon S3](/addons/amazon-s3.md)
* [ElasticSearch](/addons/elastic-search.md)
* [Memcached](/addons/memcached.md)
* [MongoDB](/addons/mongodb.md)
* [MySQL](/addons/mysql.md)
* [Papertrail](/addons/papertrail.md)
* [Postgres](/addons/postgresql.md)
* [RabbitMQ](/addons/rabbitmq.md)
* [Redis](/addons/redis.md)
* [Secure Key](/addons/securekey.md)
* [Twilio](/addons/twilio.md)

---
## For Contributors

* [Best Practices and Guidelines](best-practices-and-guidelines.md)
* [Apps API](/architecture/apps-api/apps-api.md)]
* [Creating Addons](/extending-akkeris/building-addons.md)

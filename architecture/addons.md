# Add-ons

Applications typically make use of addons to provide backing services such as databases, queueing & caching systems, storage, email services and more. Add-ons are provided as services by that may be managed by anyone \(e.g., it could be an external service that's managed by a vendor such as AWS or an internal services managed by a team member\).

Akkeris treats these add-ons as attached resources: provisioning an add-on is a matter of choosing one from the list of addon services and plans, and creating it.  In addition addons may be attached if they already exist on another application and can be shared.

For example, here's how to add an Akkeris Redis to an application:

```shell
aka addons:create akkeris-redis:small -a appname-space
```

Dynos do not share file state, and so add-ons that provide some kind of storage are typically used as a means of communication between dynos in an application. For example, Redis or RabbitMQ could be used as the backing mechanism in a queue; then dynos of the web process type can push job requests onto the queue, and dynos of the queue process type can pull jobs requests from the queue.

The add-on service provider is responsible for the service - and the interface to your application is often provided through a config var. In this example, a`REDIS_URL`will be automatically added to your application when you provision the add-on. You can write code that connects to the service through the URL, for example:

```ruby
uri = URI.parse(ENV["REDIS_URL"])
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
```

Add-ons are associated with an application, much like config vars - and so the earlier definition of a release needs to be refined. A release of your applications is not just your slug and config vars; it’s your slug, config vars as well as the set of provisioned add-ons.

### Attachments and Sharable Add-ons

Add-ons may be sharable, meaning they can be attached to other apps and used there as well.  These types of addons typically are databases and other external resources.  An example of non-sharable add-on's may include a papertrail log drain service due to the nature of the service it does not make reasonable sense to share it between apps.

An addon may be shared by using attachments. Addons can be attached to other applications through the CLI \(`aka addons:attach addon-name -a destappname-space`\) or through the [Platform Apps API](/architecture/apps-api/Services-Addons-Attachments.md) \(`POST /apps/{app}/addon-attachments`\). Add-ons may be attached across spaces so long as they have the same set of compliances on the spaces.

The original app which created the addon is considered the owner of the addon.  The owner of the addon is only allowed to delete the application.  If any app which has the addon attached is destroyed the attached addon is preserved.  If the owner app removes the addon it is detached from all subsequent attached applications then destroyed.

While it may be advantageous to use this feature for specific reasons it should generally be discouraged, be cautious and thoughtful before sharing backing resources between apps as it can cause unintended side affects such as transaction locking or a data migration on one app may cause an error on another attached app.

### Add-on Actions

Some addons have actions that can be invoked to perform special actions.  These actions are listed in the information on the addon and generally invokable via the CLI through a plugin \(such as pg plugin for postgres, or memcached plugin for memcahed\).  The dynamically defined actions can also be executed via a POST operation to the URL in the addon info `actions` array \(e.g., see `GET /apps/{app}/addons/{addon}` for more information\).

The specific actions may vary by plan and \(obviously\) service.


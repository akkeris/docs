# About Webhooks

Webhooks provide a way for notifications to be delivered to an external system via http or https whenever changes occur on an app.  Changes could include:

* Before a new release
* On a new build \(and when it succeeds or fails\)
* If features on an application are enabled or disabled
* App scale events
* Add-on creation
* Changes to config vars
* When apps are destroyed
* Creation of a preview app
* After a successful new release
* When an app crashed

Webhooks are sent by Akkeris to a URL of your chosing via https and as a `POST` request. The body of the post request will vary depending on the event that occured. To integrate with webhooks, you need to implement a server endpoint that may receive and handle these requests.

The use cases for webhooks includes:

1. Ability to kick off integration tests on a new release
2. Perform a CDN or cache operation after a build
3. Log and audit changes to applications for a status board or compliance
4. Kick off a job when an application crashes to capture logs
5. Add permissions to a shared service after its provisioned for a user

## Getting Started

To get started as quickly as possible, follow the [app webhook tutoral](/getting-started/webhooks.md)

> **info** Webhook delivery is suspended for five minutes if the response to a webhook is a HTTP status code other than a 2XX or 3XX more than twice in a five minute period.

### Step 1. Determine which events to subsribe to.

Webhooks are sent whenever a relevant event occurs, first identify which event you'd like to listen to:

| Event Name | Description |
| :--- | :--- |
| release | Used when a new release starts \(but not necessarily when it has finished\). This fires once per application. |
| build | Used when a new build starts, and also fires when it succeeds or fails.  This will fire at least twice per app. |
| feature\_change | This fires when an app's feature is enabled or disabled |
| formation\_change | If a dyno type is added, removed or changed this fires once. This includes application scale events, command changes, or health check changes. |
| logdrain\_change | This fires when a logdrain is added or removed. |
| addon\_change | This fires when an add-on is provisoned or deprovisioned. |
| config\_change | If a config var is added, removed or changed this event fires, only once. |
| destroy | Fires when an application is destroyed.  This may cause other events to fire as well \(such as addon\_change\) |
| preview | If a preview app is created based on the app this fires. |
| preview-released | If a preview app is created from a PR in source control when it releases this fires. |
| released | When a release succeeds and is the active release running this fires. |
| crashed | If a dyno crashes this will fire.  In addition if an app entirely crashes each dyno will fire as a seperate event.  This will fire as well if an application fails to shutdown gracefully when a new release is deployed. |

See [Webhook API Reference](/architecture/apps-api.md#webhook-event-payloads) for a complete list of events and their HTTP request bodies.

### Step 2. Subscribe

Using the [Apps API](/architecture/apps-api.md) or through the CLI \(`aka hooks:create`\) you can subscribe to one or more selected events on an application.  For example, if you wanted to listen to build and release events:

```shell
aka hooks:create --events "build release released" \
  https://www.example.com/my/hook --secret abc123
```

### Step 3. Secure Your Webhook

In the above example the secret `abc123` is used to calculate the SHA1 HMAC and send it with the request as the `x-appkit-signature` header with the signature prefixed with `sha1=`.  This allows you to confirm that the request coming in did indeed come from Akkeris.

While confirming the the signatures match with the secret provided is optional, it's highly recommended for security.

**Confirming an incoming webhook with node.js or Ruby on Rails**

Below are examples of how you can double check the security of a webhook in node.js or Ruby on Rails.  The process should be somewhat similar in different languages:

```javascript
// node.js

const crypto = require('crypto')
let secret = 'abc123'
let signature = req.headers['x-appkit-signature']
let payload = req.body
const hmac = crypto.createHmac('sha1', secret);
if(signature === ('sha1=' + hmac.update(payload).digest('hex'))) {
    // the request was valid.
} else {
    // the request should be ignored.
}
```

```ruby
## Ruby on Rails

require 'openssl'
secret = 'abc123'
signature = request.headers['x-appkit-signature']
payload = request.env['RAW_POST_DATA']
if signature == 'sha1=' + OpenSSL::HMAC.hexdigest('SHA1', secret, payload)
  # the request was valid
else
  # the request should be ignored
end
```

**Confirming an incoming webhook steps**

1. Ensure you have the secret (in this example `abc123`) in the app receiving the hook.
2. Get the value of `x-appkit-signature` from the headers of the incoming request.
3. Get the raw value of the request body from the incoming http request.  Do not modify, deserialize or unencode it.
4. Create a cryptogrpahic `hmac` with the `sha1` algorithm using the secret as the key (`abc123`) and the incoming body for data.
5. The result will be either a hexadecimal string or a byte array that should be converted to a hexadecimal string.
6. Prefix the hexadecimal string from step 5 with 'sha1=', lowercase everything.
7. Compare `x-appkit-signature` with the value of step 6. They should be equal.

### Step 4. Begin Receiving Webhooks

When receiving webhooks ensure your server is available and listening to `POST` http requests at the end point specified when you created the webhook.  In this example the URL where notifications and events will be sent is `https://www.example.com/my/hook`.

Depending on your event you will receive a slightly different body \(payload\).  For information on exact structures of different events see the [Webhook API Reference](/architecture/apps-api.md#webhook-event-payloads). The below example is a the payload that is sent on a `release` event.

```
POST /my/hook
Host: www.example.com
User-Agent: appkit-hookshot
Content-Type: application/json
x-appkit-signature: sha1=3abdef9381726493929abcdef2382771
x-appkit-event: release
x-appkit-delivery: 7edbac4b-6a5e-09e1-ef3a-08084a904621
```

```json
{
  "action":"release",
  "app":{
    "name":"yourappname",
    "id":"7edbac4b-6a5e-09e1-ef3a-08084a904621"
  },
  "space":{
    "name":"the-space"
  },
  "release":{
    "id":"1edbac4b-6a5e-09e1-ef3a-08084a904623",
    "result":"succeeded|failed",
    "created_at":"2016-08-09T12:00:00Z",
    "version":13,
    "description":"Auto Deploy of 31202984"
  },
  "build":{
    "id":"8bdbac4b-6a5e-09e1-ef3a-08084a904622"
  }
}
```

All web hook HTTP requests include the previously mentioned `x-appkit-signature` header but also include the `x-appkit-event` header that corresponds to the event type of the webhook allowing the destination end point to distinguish different payload types.  In addition the id of the webhook is sent as the `x-appkit-delivery` header. Finally, the user agent is set to `appkit-hookshot` to distinguish it from other webhook providers.

## Removing Webhooks

Webhooks can be removed via the CLI \(`aka hooks:destroy ID`\) or via the Platform Apps API.


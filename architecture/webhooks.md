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

## Integrations

Some webhook destinations Akkeris will identify and integrate with.  This is a special use case of webhooks called Third-Party Integrations. To add, remove or manage them use the hooks command as in previous sections but use a URL specific the service you want to integrate with.

### ![CircleCI Logo](../assets/circleci-small.png "CircleCI") CircleCI

Akkeris has the ability to integrate and kick off any existing job on Circle CI.

To kick off a new job provide the url:

```
https://circleci.com/api/v1.1/project/<vcs-type>/<org>/<repo>?circle-token=<token>
```

To kick off a new build on a specific branch provide the url:

```
https://circleci.com/api/v1.1/project/<vcs-type>/<org>/<repo>/tree/<branch>?circle-token=<token>
```

Ensure you replace `<vcs-type>` with `github` or `bitbucket`, `<org>` with your organization name on CircleCI, `<repo>` should be replaced with the name of repository. A CircleCI token is needed, replace `<token>` with the token you receive from CircleCI. Finally, if you plan to kick off a job on a specific branch replace `<branch>` with the appropriate branch on the repo. For more information on triggering builds see [CircleCI Documentation](https://circleci.com/docs/api/#trigger-a-new-job). When using CircleCI with webhooks the secret for calculating the SHA1 is not used.

The invoked CircleCI job will contain a few extra parameters that are exposed as environment variables:

* `AKKERIS_EVENT` - The name of the event that triggered the job.
* `AKKERIS_APP` - The app on akkeris that triggered the event.
* `AKKERIS_EVENT_PAYLOAD` - A JSON string containing the full webhook payload for the event. 

For more information on event payloads, see the [Webhook API Reference](/architecture/apps-api.md#webhook-event-payloads).

***Example: Kicking off a Test on CircleCI***

For example, lets say we want to kick off a test on CircleCI when an app (`testhooks-default`) is released.

1. Go to [CircleCI Personal API Tokens](https://circleci.com/account/api)
2. Click "Create New Token"
3. Name it "Akkeris testhooks-default token"
4. Copy the token that's generated.
5. Add the hook to your app (make sure to replace the token `1632345674aab11132130fffff1a4444daaa000b` with the token you received from CircleCI as well as the organization `org` and repository `repo` with your own values.

```shell
aka hooks:create -a testhooks-default -e released -s circleci 'https://circleci.com/api/v1.1/project/github/org/repo?circle-token=1632345674aab11132130fffff1a4444daaa000b'
Creating webhook ɧ https://circleci.com/api/v1.1/project/github/org/repo?circle-token=1632345674aab11132130fffff1a4444daaa000b ...  ✓ 
 id                                   2f14f1eb-a614-4917-9bf2-811ee97fd4ff
 active                               true
 events                               0=released
 created_at                           2019-09-10T20:13:44.629Z
 updated_at                           2019-09-10T20:13:44.629Z
 url                                  https://circleci.com/api/v1.1/project/github/org/repo?circle-token=1632345674aab11132130fffff1a4444daaa000b
```

When a new release is successful and the old release has been shut down, the job `repo` on the organization `org` in CircleCI will be kicked off.

You can view the hooks by running:

```shell
aka hooks -a testhooks-default
ɧ https://circleci.com/api/v1.1/project/github/org/repo?circle-token=[redacted]
  Events: released
  Id: 2f14f1eb-a614-4917-9bf2-811ee97fd4ff
  Active: true

```

Notice that the sensitive data in webhooks is automatically redacted to protect private information. Once a hook has been triggered view the results by running:

```shell
aka hooks:deliveries 2f14f1eb-a614-4917-9bf2-811ee97fd4ff -a testhooks-default
ɧ Hook Result: 1ca1d33e-542c-4066-9866-1119dada6790, 0 minutes ago - released
  > POST https://circleci.com/api/v1.1/project/github/org/repo?circle-token=[redacted]
  > x-appkit-event: released
  > x-appkit-delivery: 1ca1d33e-542c-4066-9866-1119dada6790
  > content-type: application/json
  > content-length: 364
  > user-agent: appkit-hookshot
  > x-appkit-signature: sha1=6f5c97ecce63550f213984ac4749d44825f7a1d1
  >
  > {
  >   "build_parameters": {
  >     "AKKERIS_EVENT": "released",
  >     "AKKERIS_APP": "testhooks-default",
  >     "AKKERIS_EVENT_PAYLOAD": "{\"action\":\"released\",\"app\":{\"name\":\"testhooks\",\"id\":\"7cc2b0d9-a48e-49fc-b127-44d13be333aa\"},\"space\":{\"name\":\"default\"}, \"...\":\"see webhook api reference\" }"
  >   }
  > }
  >
  < 201 Created
  < date: Tue, 10 Sep 2019 20:20:36 GMT
  < location: https://circleci.com/api/v1.1/project/github/org/repo/44
  < server: nginx
  < set-cookie: ring-session=xyz123;Path=/;HttpOnly;Expires=Thu, 10 Sep 2020 15:39:01 +0000;Max-Age=1209600;Secure
  < strict-transport-security: max-age=15724800
  < x-circleci-identity: circle-www-api-v1-694db69d86-vxm7v
  < x-circleci-scopes: :write-settings, :view-builds, :read-settings, :trigger-builds, :all, :status, :none
  < x-client-trace-id: 
  < x-frame-options: DENY
  < x-request-id: 5bb8a0c8-d9c4-4406-832d-86447d581b43
  < x-route: /api/v1.1/project/:vcs-type/:username/:repo/
  < content-length: 2854
  < connection: Close
```

### ![Microsoft Teams Logo](../assets/msteams-small.png "Microsoft Teams") Microsoft Teams

You can add webhooks to notify a MS Teams channel when specific events happen. This lets you stay in your workflow while being notified of important events. To be notified of an event via Teams, create a [Office 365 Connector](https://docs.microsoft.com/en-us/microsoftteams/platform/concepts/connectors/connectors-using). 

Once created for a channel, the URL should look similar to:

```
https://outlook.office365.com/webhook/01234567-abcd-4444-abcd-1234567890ab@98765432-dddd-5555-8888-777777777777/IncomingWebhook/1234567890abcdefedcba09876544321/ffffffff-3333-4444-5555-bbbbbbbbbbbb
```

Add this incoming webhook on any app, for any event and a notification will be sent to the channel. Note that when adding the hook, the secret used to calculate the sha1 hmac is not used by slack and can be any value.

***Example: Microsot Teams Notification when App Crashes***

For example, lets say we want to be notified in Slack when an app crashes.

1. Create a new [Office 365 Connector](https://docs.microsoft.com/en-us/microsoftteams/platform/concepts/connectors/connectors-using). 
2. Enable Incoming Webhooks and pick a channel to send notifications to.
3. Add the webhook for the `crashed` event for your app `testhooks-default`

```shell
aka hooks:create -a testhooks-default -e crashed -s msteams 'https://outlook.office365.com/webhook/01234567-abcd-4444-abcd-1234567890ab@98765432-dddd-5555-8888-777777777777/IncomingWebhook/1234567890abcdefedcba09876544321/ffffffff-3333-4444-5555-bbbbbbbbbbbb'
Creating webhook ɧ https://outlook.office365.com/webhook/01234567-abcd-4444-abcd-1234567890ab@98765432-dddd-5555-8888-777777777777/IncomingWebhook/1234567890abcdefedcba09876544321/ffffffff-3333-4444-5555-bbbbbbbbbbbb ...  ✓ 
 id                                   027aecfe-072f-49d7-927d-d8baca87e27a
 active                               true
 events                               0=crashed
 created_at                           2019-09-10T20:48:07.864Z
 updated_at                           2019-09-10T20:48:07.864Z
 url                                  https://outlook.office365.com/webhook/01234567-abcd-4444-abcd-1234567890ab@98765432-dddd-5555-8888-777777777777/IncomingWebhook/1234567890abcdefedcba09876544321/ffffffff-3333-4444-5555-bbbbbbbbbbbb
```

If your app crashes you'll be notified in the Microsoft Teams channel you selected. By selecting other events you can create notifications specific to your use case.  You can be notified when a `release` happens on an app. Or when a preview app is created with `preview`.  For more information on what types of events are available see the [Getting Started](/architecture/webhooks.md#getting-started) section above.

### ![Opsgenie Logo](../assets/opsgenie-small.png "Opsgenie") Opsgenie

Opsgenie allows you to be notified via various escalation paths when important event occurs, such as an application crashing.  Akkeris has the ability to report any event to Opsgenie as an alert. 

To create a new alert in Opsgenie, create a new [API integration](https://docs.opsgenie.com/docs/api-integration#section-using-api-integration).  Once created, you should receive a token that looks similar to:

```
ffffffff-aaaa-4444-5555-987654321000
```

It's highly recommended to assign a team when you create a new API integration, otherwise new alerts from the webhook will not be assigned. Ensure `Create and Update Access` and `Enabled` are selected when creating a new integration.

To add the opsgenie alert to a webhook add the URL:

```
https://api.opsgenie.com/v2/alerts?access_token=ffffffff-aaaa-4444-5555-987654321000
```

Or, if in Europe, use the URL:


```
https://api.eu.opsgenie.com/v2/alerts?access_token=ffffffff-aaaa-4444-5555-987654321000
```

Remember to replace the token `ffffffff-aaaa-4444-5555-987654321000` with the one created. When creating a webhook using Opsgenie the secret to calculate the sha1 hmac is unnecessary and can be set to any value. An alert can be triggered for any event.  For more information on what types of events are available see the [Getting Started](/architecture/webhooks.md#getting-started) section above.

***Example: Creating an Alert in Opsgenie When an App Crashes***

In this example we'll show how to create a new Opsgenie alert when an app called `testhooks-default` crashes. 

1. Create a new [API integration](https://docs.opsgenie.com/docs/api-integration#section-using-api-integration).
2. Name it "Akkeris Apps Crashed"
3. Ensure `Create and Update Access` and `Enabled` are checked.
4. Copy the token created by the API integration

```shell
aka hooks:create -a testhooks-default -e crashed -s opsgenie 'https://api.opsgenie.com/v2/alerts?access_token=ffffffff-aaaa-4444-5555-987654321000'
Creating webhook ɧ https://api.opsgenie.com/v2/alerts?access_token=ffffffff-aaaa-4444-5555-987654321000 ...  ✓ 
 id                                   027aecfe-072f-49d7-927d-d8baca87e27b
 active                               true
 events                               0=crashed
 created_at                           2019-09-10T20:48:07.864Z
 updated_at                           2019-09-10T20:48:07.864Z
 url                                  https://api.opsgenie.com/v2/alerts?access_token=ffffffff-aaaa-4444-5555-987654321000
```

The next time the app `testhooks-default` crashes a new alert will be created in Opsgenie and will be assigned to the team specified when the API Integration was created.

To review when a webhook fires run:

```shell
aka hooks:deliverables -a testhooks-default 027aecfe-072f-49d7-927d-d8baca87e27b
```

Where `027aecfe-072f-49d7-927d-d8baca87e27b` is the ID of the webhook.

### ![Rollbar Logo](../assets/rollbar-small.png "Rollbar") Rollbar

Rollbar can be notified of new deployments with Akkeris. This can be helpful to know if a recent deployment has caused a disruption in service. To create a new Rollbar integration an access token needs to be created. Once created you'll add a URL similar to this:

```
https://api.rollbar.com/api/1/deploy/?access_token=0066611044411888888122359668208d
```

Add this incoming webhook on any app for the event `release` and `released`. Note that other events will have a negative affect on your reported deployments. The secret used to calculate the sha1 hmac is not used by Rollbar and can be set to any value.

***Example: Reporting Deployments to Rollbar***

In this example we'll show how to add an integration to rollbar so it knows about recent deployments for a hypothetical app `testhooks-default`.  

1. Login to Rollbar.
2. Select the project associated with your app from the `Projects` drop down.
3. Click on the `Settings` menu item.
4. Click on the `Project Access Tokens` in the left hand menu.
5. Click `Create a new access token` and give it the name `Akkeris Webhooks`.
6. Add the webhook for the `release` and `released` event for your app `testhooks-default`.

```shell
aka hooks:create -a testhooks-default -e release -e released -s rollbar 'https://api.rollbar.com/api/1/deploy/?access_token=0066611044411888888122359668208d'
Creating webhook ɧ https://api.rollbar.com/api/1/deploy/?access_token=0066611044411888888122359668208d ...  ✓ 
 id                                   027aecfe-072f-49d7-927d-d8baca87e27e
 active                               true
 events                               0=release, 1=released
 created_at                           2019-09-10T20:48:07.864Z
 updated_at                           2019-09-10T20:48:07.864Z
 url                                  https://api.rollbar.com/api/1/deploy/?access_token=0066611044411888888122359668208d
```

On the next release a new deployment will be added to Rollbar. To review when the webhook fires run:

```shell
aka hooks:deliverables -a testhooks-default 027aecfe-072f-49d7-927d-d8baca87e27e
```

Where `027aecfe-072f-49d7-927d-d8baca87e27e` is the ID of the webhook. Note that sending webhooks for any event other than release or released will have no effect.

### ![Slack Logo](../assets/slack-small.png "Slack") Slack

You can add webhooks to notify slack when specific events happen. This lets you stay in your workflow while being notified of important events.

To be notified of an event via Slack, create an incoming [webhook integration](https://api.slack.com/incoming-webhooks). Once created, you should have a URL that looks similar to:

```
https://hooks.slack.com/services/X02AFNZAF/BB112GFNM/aaMlM55HHSVVNNwswIE7nnI2
```

Add this incoming webhook on any app, for any event and a notification will be sent to the channel. Note that when adding the hook, the secret used to calculate the sha1 hmac is not used by slack and can be any value.

***Example: Slack Notification when App Crashes***

In this example we'll show how to add notifications to any slack channel when an application crashes.

1. Create a new [Slack App](https://api.slack.com/apps/new). 
2. Enable Incoming Webhooks and pick a channel to send notifications to.
3. Add the webhook for the `crashed` event for your app `testhooks-default`.

```shell
aka hooks:create -a testhooks-default -e crashed -s slack https://hooks.slack.com/services/X02AFNZAF/BB112GFNM/aaMlM55HHSVVNNwswIE7nnI2
Creating webhook ɧ https://hooks.slack.com/services/X02AFNZAF/BB112GFNM/aaMlM55HHSVVNNwswIE7nnI2 ...  ✓ 
 id                                   027aecfe-072f-49d7-927d-d8baca87e27a
 active                               true
 events                               0=crashed
 created_at                           2019-09-10T20:48:07.864Z
 updated_at                           2019-09-10T20:48:07.864Z
 url                                  https://hooks.slack.com/services/X02AFNZAF/BB112GFNM/aaMlM55HHSVVNNwswIE7nnI2
```

If your app crashes you'll be notified in the slack channel you selected. By selecting other events you can create notifications specific to your use case.  You can be notified when a `release` happens on an app. Or when a preview app is created with `preview`.  For more information on what types of events are available see the [Getting Started](/architecture/webhooks.md#getting-started) section above.








# Preview Apps

<!-- toc -->
## Introduction

Preview apps run the code in any Github pull request in a complete, disposable app on Akkeris.  Each preview app has a unique URL that you can share.  In addition, if the app is placed in any site, unique sites will be created with the code in the pull request. 

## Enabling Preview Apps

To use preview apps, the four conditions must be true:

1. You've enabled preview apps feature `aka features:enable preview -a [appname-space]`
2. The app is connected to a Github repo `aka repo -a [appname-space]`
3. Your app was connected to the Github repo after April 1st 2018.  A change took place on April to add `pull_request` events to the events received when attached to a repo, this however is not retro active, if your app was attached prior to this you may need to unset then reset it using `aka repo:unset` and `aka repo:set`.
4. Your app is not in a `socs` or `prod` space.

## Creating a preview app

Once you've properly setup preview apps, submit a pull request to the branch Akkeris is listening to. The URL for your preview app is available on creation – in GitHub (in the deploy message area) and within the pull request timeline.

---

![Pull request on Github with Preview App](/assets/previewapps.png)

---

Once the preview app has been created for a given pull request, you can run it in a browser (at the preview app URL). The URL is available from the "View deployment" button within the Github pull request.  In addition you may listen to the [web hook](/architecture/webhooks.md) `preview` to receive the preview app URL and other information.  This can be especially useful for invoking tests against pull requests.

## App Lifecycle

A preview app is created when a pull request is opened (or reopened) to a branch and repo that an Akkeris app is listening for changes on. More than one preview app may exist at any point in time.  The preview app is marked in the CLI and UI as preview to show its temporary nature, while short living it behaves exactly like a normal application with the same ability to modify it independently of its original app (e.g., modify config vars, add addons, etc).

Only one instance of the `web` dyno is created in the preview app.  Destructive actions in Akkeris should generally be placed in a `release` dyno type or `worker` dyno type.  If this convention is adhered to preview apps will have no negetive affect on the source app as only the `web` instance is created automatically.

When the pull request is closed (either merged or discarded) the preview app is automatically removed.  In addition the preview app is removed after three business days if no action is taken on the PR. The preview app is like any other app, it can explicitly be deleted using `aka apps:destroy`.  

## Inheriting config vars, log-drains and addons

Preview apps will be attached to any existing addons on the original app.  They will also receive (automatically) new addons if the addon on the original app is not sharable. The same user-defined config vars are placed within the preview app as the original app.  Finally, all existing log drains are added to the preview app as well. 

> **danger**
> Any addons created and added to the preview app will be automatically destroyed (save the addons attached from the source app).  If new addons are created on the preview app be careful to keep backups of any data or resources on the addon.

## Sites and Routes

When a preview app is created any sites it exists in are re-created with the same routes, except the preview app replaces the original app.  The new site is given a random unique name with a similar prefix and subdomain. The name of the site (and URL) is delivered on the `preview` [web hook](/architecture/webhooks.md) to assist with integration tests prior to merging the pull request.

When the preview app is removed the sites and routes created along side it are automatically destroyed as well.

## Disabling Preview Apps

You may disable preview apps at any time using the CLI or [Platform Apps API](/architecture/apps-api/Features.md):

```
aka features:disable preview -a [appname-space]
```

> **danger**
> Disabling preview apps on the source app will automatically delete all preview apps (and any addons created for them).
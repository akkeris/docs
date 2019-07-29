---
template: guide
---

# Getting Started on Akkeris with Node.js

## Table of Contents

<!-- toc -->

## Introduction

In this tutorial you will deploy a node.js app in minutes.

Hang on after the tutorial for a few minutes to find out how Akkeris works and other information so you can make the most out of Akkeris and its dev tooling.

Before we proceed make sure you're comfortable with Terminal concepts and have access to a terminal on Windows, macOS, or Linux.  If you need to brush up on your terminal skills [read through this terminal guide first](https://computers.tutsplus.com/tutorials/navigating-the-terminal-a-gentle-introduction--mac-3855).

You'll also need to ensure you have \(at a bare minimum\) [node.js](https://nodejs.org) \(8+\) installed \(for the CLI system\).  Be sure to check our [prerequisites](/prerequisites-and-installing.md) to ensure you can make the most out of Akkeris.

* [I'm ready to start](#set-up)

## Set up

In this step you will install the Akkeris Command Line Interface \(CLI\), or AppKit as its sometimes referred to. You will use the CLI to manage and scale your applications, to provision add-ons, to install plugins from other engineers on your teams, to view the logs of your application as it runs on Akkeris, to pull logs from legacy apps, as well as to help run your application locally.

Install Akkeris:

```bash
$ npm -g install akkeris
```

_Note, if you receive an error about insufficient permissions you may need to run _`sudo npm -g install akkeris`_ instead._

Then type:

```bash
$ aka

Hi! It looks like you might be new here. Lets take a second
to get started, you will need your akkeris auth and apps host
in addition to your login and password.

Akkeris Auth Host (auth.example.io): auth.example.io
Akkeris Apps Host (apps.example.io): apps.example.io
Profile updated!
Username: first.lastname
Password: ******
Logging you in ...  ✓
```

Note that after you login you may see a list of commands available.

* [I have installed node.js, akkeris and logged in.](#create-the-app)


## Create the app

In this step, you will prepare a simple application that can be deployed.

```bash
aka apps:create -s voltron -o test
Creating app ⬢ digestion1077-voltron ...  ✓ 
https://digestion1077-voltron.alamoapp.example.io/
```

This will create a new app with a randomly generated name `digestion1077` in the space`voltron`, assigned to our testing organization. You can pass a parameter to specify your own app name.

> Your application name may vary, keep a note of your randomly generated app name as you'll need it later, you can also create an app with a specific name by passing it in as an arguement to the command above.

Now deploy the image `quay.example.io/developer/node-boilerplate:v1` to the app:

```bash
aka releases:create -a digestion1077-voltron docker://quay.example.io/developer/node-boilerplate:v1
Deploying ⬢ docker://quay.example.io/developer/node-boilerplate:v1 to digestion1077-voltron  ...  ✓ 
```

You can watch the app logs (including its build and release) with the command below. Remember to press CTRL+C to stop watching the logs once you see the `Node app is running on port 9000`:

```bash
aka logs -t -a digestion1077-voltron
2018-04-09T16:21:42Z digestion1077-voltron akkeris/build: 87de37a50d56: Pushed
2018-04-09T16:21:49Z digestion1077-voltron akkeris/build: 2c40c66f7667: Pushed
2018-04-09T16:21:54Z digestion1077-voltron akkeris/build: 4e46330a61be: Pushed
2018-04-09T16:21:59Z digestion1077-voltron app[web.akkeris/event]: Slug compilation finished
2018-04-09T16:22:02Z digestion1077-voltron app[web.akkeris/event]: Release v1 created (Auto-Deploy b7a27c7f)
2018-04-09T16:22:07Z digestion1077-voltron app[web.2453604099-0lcnh]: npm info it worked if it ends with ok
2018-04-09T16:22:07Z digestion1077-voltron app[web.2453604099-0lcnh]: npm info using npm@5.3.0
2018-04-09T16:22:07Z digestion1077-voltron app[web.2453604099-0lcnh]: npm info using node@v8.4.0
2018-04-09T16:22:07Z digestion1077-voltron app[web.2453604099-0lcnh]: npm info lifecycle node-js-getting-started@0.2.5~prestart: node-js-getting-started@0.2.5
2018-04-09T16:22:07Z digestion1077-voltron app[web.2453604099-0lcnh]: npm info lifecycle node-js-getting-started@0.2.5~start: node-js-getting-started@0.2.5
2018-04-09T16:22:08Z digestion1077-voltron app[web.2453604099-0lcnh]: 
2018-04-09T16:22:08Z digestion1077-voltron app[web.2453604099-0lcnh]: > node-js-getting-started@0.2.5 start /usr/src/app
2018-04-09T16:22:08Z digestion1077-voltron app[web.2453604099-0lcnh]: > node index.js
2018-04-09T16:22:08Z digestion1077-voltron app[web.2453604099-0lcnh]: 
2018-04-09T16:22:08Z digestion1077-voltron app[web.2453604099-0lcnh]: Node app is running on port 9000
```

You've successfully deployed your new application! Open your deployed application in the browser by running:

```bash
aka apps:open -a digestion1077-voltron
```

If it does not appear give it a few seconds to start up.

* [I understand how to create and deploy an app with a docker image.](#attaching-your-app-to-github)


## Attaching your App to Github

Most applications are deployed via a source control repository such as GitHub. This is called an auto build.  In this section we'll learn how we can automatically attach our app to Github and deploy code as commits are made.

### Create a new github repo

In this example you'll need to create a new repo on GitHub, you can create it under your corporate account or under your personal account. You can do this at [https://github.com](https://github.com/).

Now open up a terminal and we'll clone out your repo:

```bash
git clone https://github.com/[org]/[repo]
```

Once its cloned, ensure you run `cd [repo]` as we'll write some files to your new repo. Lets first populate it with a default node.js app, to do this first run `npm init -y` and accept all the default values.

```bash
npm init -y
```

Then we'll install express:

```bash
npm install -y express
```

Now lets add some code to the `index.js` file:

```bash
cat > index.js <<EOF
const express = require('express')
const app = express()

app.get('/', (req, res) => res.send('Hello World.'))

app.listen(9000, () => console.log('Example app listening on 9000'))
EOF
```

To deploy to Akkeris a special file at the root of the repository called a `Dockerfile` \(case sensitive\) is needed.  It is auto detected by Akkeris and tells it how to start your application, and how to build your application.

To create a Dockerfile run:

```bash
cat > Dockerfile <<EOF
FROM node:8
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . /usr/src/app
RUN npm install
EXPOSE 9000
CMD [ "node", "index.js" ]
EOF
```

### Attach Github to your app

Next, set your app to automatically deploy anytime there's a change on the repo:

```bash
aka repo:set https://github.com/[org]/[repo] -t [token] \
  -u [github username] -a digestion1077-voltron
```

Note, you can use the token you generated when you setup your [Github CLI](/getting-started/prerequisites-and-installing.md#setting-up-github-account-on-the-cli).

### Trigger a new deploy

Now any change to your repo will create a new build. You can create a new commit by first adding your new files:

```bash
git add package.json index.js Dockerfile
```

Then commiting them:

```bash
git commit -a -m 'Triggering deploy'
[master d3c552b] Trigger deploy
```

Now push your changes to trigger the deploy:

```bash
git push
Counting objects: 22, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (16/16), done.
Writing objects: 100% (22/22), 3.10 KiB | 0 bytes/s, done.
Total 22 (delta 13), reused 0 (delta 0)
remote: Resolving deltas: 100% (13/13), completed with 12 local objects.
```

To watch your [logs](/architecture/log-drains.md), run:

```bash
aka logs -t -a digestion1077-voltron
```

Note the `-t` in the command above means to tail the logs, it keeps showing new logs until you press CTRL+C to stop it. Once the logs show `Example app listening 9000` its up and running, remember to press CTRL+C to stop watching the logs.

You've successfully attached and deployed your code from Github!  To see your application run:

```bash
aka apps:open -a digestion1077-voltron
```

If it does not appear give it a few seconds to start up.

* [I understand how to attach Github to my app](#scale-the-app)


## Scale the app

Right now, your app is running on a single [dyno](//architecture/dyno.md). Think of a dyno as a lightweight container \(in fact in the docker world is it a container\) that runs the specified command in your [Dockerfile](https://docs.docker.com/engine/reference/builder/).

You can now check how many dynos are running us the`ps`command:

```bash
aka ps -a digestion1077-voltron
=== web (scout): (from docker) (1)
web.2885060676-76szt: up 10/27/2017, 2:36:42 PM
```

By default, your app is deployed on a small dyno \(a scout size\). And only one dyno type "web". Dyno types specify what special considerations your process may need when it starts, the dyno type "web" indicates it should be given a URL on the web, it also tells alamo to direct its web traffic to the port specified with the`$PORT`environment variable in your configuration. You should listen to the`$PORT`environment configuration variable to receive web traffic and respond to it.

You can also create new dyno types or scale existing dyno types using `aka ps:update`. For example, you can change the amount of servers your application is running on to zero by doing:

```bash
aka ps:update -q 0 -a digestion1077-voltron
...
```

If you then open up your app using `aka apps:open -a digestion1077-voltron` you will get an error message since the application is no longer running.

You can scale it back up again by running:

```bash
aka ps:update -q 1 -a digestion1077-voltron
```

If you need to run background processes you can create a new process type using `aka ps:create worker -c [command] -a digestion1077-voltron`. This will create a new background process called `worker` that can be scaled independently of your web dyno. It will receive the same code and deployments and configuration but does not need to listen to web traffic or respond on a port. It can independently run background processes as needed.

* [I know how to scale my app](#define-config-vars)
* [Report a problem](#)

## Define config vars

Akkeris allows you to store configuration information outside of your code. Storing data such as encryption keys or API URL's as [config vars](/architecture/config-vars.md) allows you to have one code base and branch run on multiple environments and gives you a space where confidential information can be stored and retrieved.

At runtime, config vars are exposed as environment variables to the application \(e.g., `process.env.MY_VARIABLE`\). For example, modify `index.js` so that it introduces a new route, `/times`, that repeats an action depending on the value of the `TIMES` environment variable:

```js
app.get('/times', function(request, response) {
    var result = ''
    var times = process.env.TIMES || 5
    for (i=0; i < times; i++)
      result += i + ' ';
  response.send(result);
});
```

Then you'll need to commit and push the changes to your github using `git commit -a -m 'Testing config vars'` and `git push`.

To set the config var on Akkeris, execute the following:

```bash
aka config:set TIMES=2 -a digestion1077-voltron

=== digestion1077-voltron Config Vars
 PORT                                 9000
 TIMES                                2
```

View the config vars that are set using `aka config`:

```bash
aka config -a digestion1077-voltron

=== digestion1077-voltron Config Vars
 PORT                                 9000
 TIMES                                2
```

Now that the config var is added open your app using `aka open -a digestion1077-voltron` and change the path to /times, you should see the value `0 1`.

* [I understand config vars](#provision-add-ons)


## Provision add-ons

[Add-ons](/architecture/addons.md) are third-party [services](/architecture/addons.md) or shared credentials that provide out of the box additional functionality for your application, from databases, persistence, s3 buckets through logging to monitoring and more. You can view a list of all of the services you can attach to your application as an addon using:

```bash
aka services
```

You can then view plans for each service by running `aka services:plan`.  For example, to view all of the plans for a postgresql database you can run:

```bash
aka services:plans akkeris-postgresql
```

You can then provision addons from a service plan by running `aka addons:create [service]:[plan]`,  you can provision a small database by running:

```bash
aka addons:create akkeris-postgresql:standard-0
```

Note that the connection information for the service provisioned are added as config vars. You can view the new config vars created by the provisioned database by running `aka config -a digestion1077-voltron`.

In this next example we'll show how to provision papertrail as a service.  Note that all services for Akkeris are provisioned via addons.

### Provisioning Papertrail Services

By default akkeris does not store any of your logs from your application or http requests. However, it makes the full log stream available as a service - this is called a log drain. A log drain is a syslog or http end point where your logs will be forwarded to by alamo.

In this step we'll provision an addon that will add a log drain to your app, Papertrail. Papertrail allows searching, storing and alerting based on logs online a [https://papertrailapp.com](https://papertrailapp.com/). 

Provision the papertrail logging add-on:

```bash
$ aka addons:create papertrail:basic -a digestion1077-voltron

=== Addon papertrail-camera-5168 Provisioned
=== papertrail-camera-5168 (f5a86fae-b54f-481f-a8c8-006942541ee8)

...
```

The add-on is now deployed and configured for your application. You can list add-ons that are installed for your app using:

```bash
$ aka addons -a digestion1077-voltron
```

If you visit [https://papertrailapp.com/systems/digestion1077-voltron/events](https://papertrailapp.com/systems/digestion1077-voltron/events) you can see the logs from your application, it may take a second or two for them to appear. The interface also allows you to setup searches and alerts.

* [I know how to provision services and credentials](#next-steps)
* [Report a problem](#)

## Next Steps

You now know how to deploy an app, change its configuration, view logs, scale, and create add-ons from services.

Here’s some recommended reading. The first, an article, will give you a firmer understanding of the basics. The others may interest you in how you can best take advantage of Akkeris.

* Read [How Akkeris Works](/how-akkeris-works.md) for more a technical overview you'll encounter while writing, deploying, running and managing applications on Akkeris.
* Read [Best Practices and Guidelines](/best-practices-and-guidelines.md) for more information on how you can take full advantage of Akkeris and other developer workflow tips and tricks.
* Read [Extending Akkeris](/how-to-extend-akkeris.md) to learn how you can use the Platform Apps API, shared credentials and create custom addons to extend its funtionality and introduce customized workflows or features.

### Have Questions?

* Join our slack channel at \#akkeris (akkeris.slack.com)





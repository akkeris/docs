# Learning to use Akkeris Apps API

The [Apps API](/architecture/apps-api/apps-api.md) allows you to extend Akkeris and provide functionality beyond what is provided out of the box.  In this tutorial, we'll use a popular CLI tool `curl` to explore the Apps API. Every popular language has the ability to make these same calls programmatically, see your language to find out how to make http and https calls.

By the end of this tutorial you should be able to:

1. Make requests to the API.
2. Authenticate with the API.
2. Explore the [Apps API](/architecture/apps-api/apps-api.md) reference.

## Prerequisites

1. In order to get started, you'll need to understand the basics of Command Line Interfaces (CLI's), URLs, and HTTP. If you feel uncomfortable with these subjects, start by learning about [CLI's](https://www.codecademy.com/learn/learn-the-command-line), then move on to learning about [URLs and HTTP methods using curl](https://curl.haxx.se/docs/httpscripting.html).
2. It is assumed you'll be working on a MacOS or Linux based system (although Windows would work as well, but may require some translation).
3. It is assumed you have access to akkeris already and the `aka` toolchain installed. If not, see the [Getting Started](/getting-started/prerequisites-and-installing.md) section.
4. Finally, its assumed you'll have `curl` and `jq` installed. 

If you do not have curl or jq installed, continue on to the "Opening Your Terminal" and return here, if you are confident you do, you may skip this step.

Run the following command in your terminal:

```shell
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```
```shell
brew install curl
```
```shell
brew install jq
```

Or, on Linux:

```shell
sudo apt-get update
sudo apt-get install jq
```

## Exercise - Opening Your Terminal

The process for opening a terminal on Linux depends on the specific distribution. For example, on Debian, you can [follow these instructions](https://wiki.debian.org/Console).

To open a terminal on MacOS:
1. Click on the "Finder" in the Dock.
2. With an open "Finder" click on "Applications" on the left hand side.
3. In the column to the right it should show a list of applications, and folders. Find the folder labeled "Utilities" and open it.
4. Find the application "Terminal" and open it.

Congratulations! You just learned how to open your terminal in MacOS. The next exercise you'll explore curl and the aka command line to make calls to akkeris.

## Exercise - Making Akkeris Apps API Requests

### Ensure you're logged in

With the terminal open, type `aka wohami`. It should show your name and email (or username) depending on your installation. 
>If you recieve an un-authorized error, login again using `aka auth:login` then continue on.

### Retrieve your token

Type `aka token`. This will return a special series of numbers and letters that is your **password** of sorts on akkeris.  Do not disclose this or let anyone else have it, as it gives them access as **you** to akkeris. 
>If you get an error, try loggig in again with `aka auth:login` then continue on.

### Save your token

To save your token, run: 

```shell
export AKKERIS_TOKEN=`aka token` 
``` 

This will store the token from Step 2 into an easy-to-remember enviornment variable, `AKKERIS_TOKEN`, that we can reference in any command by typing `$AKKERIS_TOKEN`. The value `$AKKERIS_TOKEN` in future calls will be replaced with the actual token you saw in Step 2. 

You can confirm that the token is saved by running `echo $AKKERIS_TOKEN`- you should see your token as you did in Step 2.  
>If not, you may be using Windows or a type of Linux shell that does not support posix standards. In windows, try using `set AKKERIS_TOKEN=...` where `...` should be replaced with your token. You can then use `%AKKERIS_TOKEN%` to make calls rather than `$AKKERIS_TOKEN`.

### Retrieve your Akkeris Host

Each Akkeris instance has its own unique host. This is the server that we will make requests to. Typically, this is stored in a configuration file within your home directory (`~/.akkeris/config.json`). To find out your Akkeris host, type the following command in your terminal:

```shell
cat ~/.akkeris/config.json | jq '.apps' -r
```

>If you already have your host you can skip this step; if you're using Windows you'll need to find out your Akkeris host from a friend or an administrator. If you receive a 'jq' command not found, you'll need to install jq.  See the prerequisites above.

### Save your Akkeris Host

Run the following command:

```shell
export AKKERIS_HOST=`cat ~/.akkeris/config.json | jq '.apps' -r`
```

You can confirm it was successful by running `echo $AKKERIS_HOST` - it should print the same host name you saw in the previous step.

### Make your first Akkeris API Request

To make your first request, we'll need to construct a `curl` CLI command.  CURL will make an http request for us and return the results of the request back to the Terminal.

```shell
curl https://$AKKERIS_HOST/apps
```

You should see the following response:

```
Unauthorized
```

This implies we did not pass in our authorization token. We can see more information by running `curl` in verbose mode:


```shell
curl https://$AKKERIS_HOST/account -v
```

You should receive a response similar to the following:

```http

* Trying 1.2.3.4...
* TCP_NODELAY set
* Connected to apps.akkeris.io (1.2.3.4) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* Cipher selection: ALL:!EXPORT:!EXPORT40:!EXPORT56:!aNULL:!LOW:!RC4:@STRENGTH
* successfully set certificate verify locations:
*   CAfile: /etc/ssl/cert.pem
  CApath: none
* TLSv1.2 (OUT), TLS handshake, Client hello (1):
* TLSv1.2 (IN), TLS handshake, Server hello (2):
* TLSv1.2 (IN), TLS handshake, Certificate (11):
* TLSv1.2 (IN), TLS handshake, Server key exchange (12):
* TLSv1.2 (IN), TLS handshake, Server finished (14):
* TLSv1.2 (OUT), TLS handshake, Client key exchange (16):
* TLSv1.2 (OUT), TLS change cipher, Client hello (1):
* TLSv1.2 (OUT), TLS handshake, Finished (20):
* TLSv1.2 (IN), TLS change cipher, Client hello (1):
* TLSv1.2 (IN), TLS handshake, Finished (20):
* SSL connection using TLSv1.2 / ECDHE-RSA-AES256-GCM-SHA384
* ALPN, server did not agree to a protocol
* Server certificate:
*  subject: C=US; ST=Utah; L=Salt Lake City; O=Akkeris; OU=IS; CN=*.akkeris.io
*  start date: Jun 18 00:00:00 2018 GMT
*  expire date: Jun 22 12:00:00 2020 GMT
*  subjectAltName: host "apps.akkeris.io" matched cert's "*.akkeris.io"
*  issuer: C=US; O=DigiCert Inc; OU=www.digicert.com; CN=DigiCert SHA2 High Assurance Server CA
*  SSL certificate verify ok.
> GET /account HTTP/1.1
> Host: apps.akkeris.io
> User-Agent: curl/7.54.0
> Accept: */*
> 
< HTTP/1.1 401 Unauthorized
< Content-Type: text/plain; charset=utf-8
< Content-Length: 12
< Date: Sun, 28 Jul 2019 22:53:38 GMT
< Connection: keep-alive
< Strict-Transport-Security: max-age=16070400; includeSubDomains
< 
* Connection #0 to host apps.akkeris.io left intact
Unauthorized                          
```

This shows the details of the request and response in addition to the actual text of the response (`Unauthorized`). At any time you can add `-v` to the curl request to see more details. While this reponse is much more verbose, you can safely ignore some parts of it. Parts beginning with `*` are information about how the HTTP connection was encrypted. For our uses you may ignore all of this. Parts beginning with `>` detail HTTP information about the **request** to Akkeris, including HTTP headers. Parts beginning with `<` contian details about the HTTP **response** from Akkeris. Most importantly, the response code- which in thihs case is `401`

The response code following the `< HTTP/1.1` text (`401`) is called a status code and will indicate whether or not the request was successful. In this case, a `401` indicates an unauthorized request. A `403` indicates the request was authorized, but still not allowed (most likely due to constraints set by your administrator).

To add authorization, we'll add in the `$AKKERIS_TOKEN` to the request to let Akkeris know who we are and that we're authorized:


```shell
curl https://$AKKERIS_HOST/account -H "Authorization: Bearer $AKKERIS_TOKEN" | jq .
```

This should now return your account details:

```json
{
	"allow_tracking":true,
	"beta":false,
	"created_at":"2015-01-12T16:28:48.000Z",
	"elevated_access":true,
	"email":"your.name@example.com",
	"id":"869793c6-0452-c3ce-81cc-6812fc04bb21",
	"last_login":"2019-07-19T00:16:07.007Z",
	"name":"Your Name",
	"sms_number":"+1 555 555 5555",
	"suspended_at":null,
	"delinquent_at":null,
	"two_factor_authentication":false,
	"updated_at":"2019-07-09T20:38:36.000Z",
	"verified":true
}
```

You may notice the text coming back is in a popular JSON (JavaScript Object Notation) format. This format can be parsed by any language and used to exchange information to and from Akkeris.

To let Akkeris know who you are you must add an http header "Authorization" with the value "Bearer [your-bearer-token]" to the http request. Using curl, we do this by adding `-H "Authorization: Bearer $AKKERIS_TOKEN"` to the command.  Remember `$AKKERIS_TOKEN` is automatically replaced with your bearer token that you saved earlier. The colon (`:`) between Authorization and Bearer tells curl which part of the string is the header name, and the header value. There are other headers that can affect requests, but this one `Authorization` is the most important one to remember.


### Create an App via the Akkeris Apps API

For this step, you'll need to choose a space and organization.  Do not choose a space that has `socs`, `prod` or other compliace limitations. Use an organinzation meant for tests, usually named `test` or `testing`.  
>If you're unsure which space and organization to use to use, ask a friend or co-worker.  To see a list of spaces run `aka spaces`, and to see a list of organizations run `aka orgs`.

To create a new app, you'll need to make a new request to Akkeris via a http method: `POST`. There a several types of http methods, including `DELETE`, `GET`, `PATCH`, `POST` and `PUT`.  By default, if you do not specify a http method in curl it uses `GET`.  By convention, creations generally are `POST` actions, while deletions are, well, `DELETE`.  `POST`, `PUT` and `PATCH` methods allow you to send information with your request, such as (in this case) the app name.

In this example, we'll create an app called `monty` in space `nice` with the org `testorg`.  You can choose your own app name if you'd like, but it must be less than 24 characters and can only contain letters and numbers (and must begin with a letter). You cannot use dashes, or underscores in app names.  Replace `nice` with the space you selected, and likewise `testorg` with your org. 

```shell
curl https://$AKKERIS_HOST/apps -H "Authorization: Bearer $AKKERIS_TOKEN" \
	-X POST \
	-d '{"org":"testorg", "name":"monty", "space":"nice", "description":"my app"}' \
	-H 'content-type: application/json' | jq .
```

You should see the response:

```json
{
	"archived_at":"2019-07-28T23:22:40.071Z",
	"buildpack_provided_description":"default",
	"build_stack":{
		"id":"ffa8cf57-768e-5214-82fe-fda3f19353f3",
		"name":"ds1"
	},
	"created_at":"2019-07-28T23:22:40.071Z",
	"description":"my app",
	"git_url":null,
	"git_branch":null,
	"id":"f5a45fd8-0b46-4ed5-99d6-ba0005282bf7",
	"labels":"",
	"maintenance":false,
	"name":"monty-nice",
	"simple_name":"monty",
	"key":"monty-nice",
	"owner":{
		"email":"",
		"id":"a3bf4f1b-2b0b-822c-d15d-6c15b0f00a08"
	},
	"organization":{
		"id":"8c125719-ae31-4365-a863-42627190732b",
		"name":"testorg"
	},
	"formation":{
		"size":null,
		"quantity":null,
		"port":null
	},
	"preview":null,
	"region":{
		"id":"f5f1d4d9-aa4a-12aa-bec3-d44af53b59e3",
		"name":"us-seattle"
	},
	"released_at":null,
	"repo_size":0,
	"slug_size":0,
	"space":{
		"id":"ee6d506c-a2b3-4384-9998-0f092e33eb71",
		"name":"nice",
		"compliance":""
	},
	"stack":{
		"id":"ffa8cf57-768e-5214-82fe-fda3f19353f3",
		"name":"ds1"
	},
	"updated_at":"2019-07-28T23:22:40.071Z",
	"web_url":"https://monty-nice.ds1.akkeris.io/"
}
```

You'll notice a few new options we added to curl- `-X POST` tells curl to make send a http method `POST` or to create. The `-d` followed by the JSON contents are the optional (additional) information we send to Akkeris to complete the request. The new header we added with `-H 'content-type: application/json'` tells Akkeris the additional information is encoded with JSON. The key and values inside this JSON content are documented in the [Apps API](/architecture/apps-api/apps-api.md) and vary depending on the request. 

***Congratulations!***

 You just created your first application directly via the Akkeris Apps API.  This is exactly what happens in both the UI and CLI when you create an application (e.g., `aka apps:create`).  In fact, everytime you interact with Akkeris, you do so through this API via a client (typically the UI or CLI). 

### Remove an App via Akkeris Apps API

To remove an app, we change the `POST` method to a `DELETE` method. To remove your app, in our situation called `monty-nice`, run the following command (remember to replace the app name with the name you used).

```shell
curl https://$AKKERIS_HOST/apps/monty-nice -X DELETE -H "Authorization: Bearer $AKKERIS_TOKEN"
```

### Next Steps

* Read through the [Apps API Reference](/architecture/apps-api/apps-api.md) for other commands you can call.
* Learn about [Plugins](/architecture/plugins.md), which allows you to add functionality to the `aka` CLI.
* Learn about [Webhooks](/architecture/webhooks.md), this lets you listen to changes and events in Akkeris (such as releases).




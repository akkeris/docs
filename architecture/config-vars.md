# Config Vars

An application’s configuration is everything that is likely to vary between environments \(staging, production, developer environments, etc.\). This includes backing services such as databases, credentials, or environment variables that provide some specific information to your application.

Akkeris lets you run your application with a customizable configuration - the configuration sits outside of your application code and can be changed independently of it.

The configuration for an application is stored in config vars. For example, here’s how to configure an encryption key for an application:

```shell
aka config:set ENCRYPTION_KEY=my_secret_launch_codes -a appname-space
Adding config vars and restarting demoapp... done, v14
ENCRYPTION_KEY=my_secret_launch_codes
```

Config vars contain customizable configuration data that can be changed independently of your source code. The configuration is exposed to a running application via environment variables.

At runtime, all of the config vars are exposed as environment variables - so they can be easily extracted programatically. A node.js application deployed with the above config var can access it by calling`process.env.["ENCRYPTION_KEY"]`.

All dynos in an application will have access to the exact same set of config vars at runtime.

Config vars can be set through the CLI \(`aka config:set`\), the UI or through the Platform Apps API \(`PATCH /apps/{app}/config-vars`\). Note that any change to a config var will create a new deployment.

### User Config Vars

A config var which is set by a user is a user config var.  This contrasts with config vars that are either added by services, or by the platform. Config vars set by the user are always modifiable by the user \(and removable\).  Note if you find the value \[redacted\] being shown for a user config var you've set, see the [Sensitive Config Vars](#sensitive-config-vars) section.

### Service Config Vars

A service config var is an environment variable injected into an application by an addon, for example if a postgresql addon was created on an app it would inject a config var named DATABASE\_URL.  This config var is a service config var which has a few limitations.  The first is it is not modifiable, any attempt to change the value will result in an error from the Platform Apps API, the UI, and CLI. The second is that it appears automatically when the addon is created, and is removed when the addon is destroyed.

The service config vars name's vary by addon and are defined by the provider of the service. The names of the keys \(e.g., `DATABASE_URL`\) cannot be changed.

### Credential Config Vars

Some config vars are injected from shared credentials that are provisioned from services.  These also have some special properties as they may be redacted and unviewable regardless of what space and compliances are set on the application.  Seeing a value of \[redacted\] indicates that you are unable to view these values due to the sensitive nature of the value. However your application when running will be able to see the real value.

### Sensitive Config Vars

Within `socs` and sometimes `prod` spaces Akkeris will automatically identify what it may consider sensitive information. This could include user config vars hat appear to store a password, token or other sensitive data.  Akkeris may also identify sensitive information in a portion of a config var, such as the password portion of a URL.

Any time Akkeris finds a sensitve peice of information in a `socs` \(and sometimes `prod`\) compliant space it is automatically replaced with the text `[redacted]`.  While this information is unviewable when viewing config vars to the user it is still fully available to the application when it launches.

### Pulling Config and Local Development

To help ease the burden of local development, in compliant spaces you can pull down the configuration of an app to your local machine and run an application with it. This allows users to quickly boot up an application locally with the exact same config an app is using in an environment.  Change to the directory of your local app and run:

```shell
aka config -a appname-space -s > .env ; source .env 
```

Then start the application as normal.  Note that the config is now stored in the `.env` file, becareful to not commit this into source control as it may contain sensitive information.  Add the `.env` to your `.gitignore` file to ensure this does not happen.

### Injected Runtime Config Vars

`AKKERIS_DEPLOYMENT`

This environment variable contains the name of the application in Akkeris. For example if an application is named `myapp-space` this value would be set to `myapp`.


`AKKERIS_APPLICATION`

This environment variable contains the name of the application key in Akkeris. For example if the application is named `myapp-space` this value would be `myapp-space`.

`AKKERIS_SPACE`

This environment variable contains the name of the space the application is in. For exampe if the application is named `myapp-space` this value would be `space`.

### Injected Build Config Vars

Environment variables are added to builds in Akkeris so that usernames and passwords to private repositories or artifact servers can be accessed. Any user defined config-var (e.g., not a config variable added by a database or addon) will be also added and injected into your docker build. In addition the following environment variables are added containing information on what caused the build to occur:

`AKKERIS_GIT_SHA1`

The SHA1 commit hash for the current build.

`AKKERIS_GIT_BRANCH`

The git branch being built.

`AKKERIS_GIT_REPO`

The URL of the git repo being built.


# ![Secure Key Logo](../assets/securekey-small.png "Secure Key")  Secure Key

<!-- toc -->


## Introduction

Secure Key is an addon that adds the ability to gracefully rotate tokens and keys. 

Apps may require random keys for things like signing cookies, shared credentials or encryption.  The secure key addon provides an always fresh, unguessable secret for these purposes. It can be used anywhere in your application that may require some source of randomness or secret token.  Secure Key places these random keys in your environment and encourages good practices by allowing the key to be rotated periodically.

Secure Key is especially perfect for encrypting cookies or databases as it provides two keys, when keys are rotated the oldest is removed and a new key is created.  This ensures that there isn't a discontinuity when keys are rotated between the old and new ones (keys are slowly rotated out rather than abruptly using multiple keys).

## Set up

Before we get started, ensure you have the secure key plugin installed on your command line.

```shell
aka plugins:install securekey
```

### Provisioning the add-on

Secure Key can be attached to an application using the CLI, UI or Platform Apps API:

```shell
aka addons:create securekey:fortnightly -a [appname-spacename]
```
Once Secure Key has been added, `SECURE_KEY` will be available in the apps config-vars and environment.  This contains two 32 byte hexadecimal (string encoded) securely generated keys seperated by a comma. You can view the value of this in your app (so long as its not in a `prod` or `socs` space) via:

```shell
aka config -a [appname-space]
SECURE_KEY		2fi9ugflsiscwcdv3g2aq2v2c2nwam2elripnkjbn1s6n5m6c4,6c7r6pz375bhltbvt57slj5waqj3fw1t7hc0u8bqwda0sqdth5
```

The key is formatted as `<CURRENT_KEY>,<OLD_KEY>`.  After the appropriate amount of time (or anytime the secure key is rotated) `CURRENT_KEY` will be moved after the comma becoming the old key, and a fresh key will be put before the comma.

```shell
aka securekey:rotate -a [appname-space] ; aka config -a [appname-space]
SECURE_KEY		5ea4dgflsiscwcdv3g2aq2v2c2n3112elripnkjbn1s6n5m655,2fi9ugflsiscwcdv3g2aq2v2c2nwam2elripnkjbn1s6n5m6c4
```

### Attaching to other apps

Another use case of Secure Key is providing a shared secret among multiple apps for authentication or cookie signing.  Normally it may be quite a pain to manually rotate the keys that are shared among multiple apps, but by attaching the Secure Key addon each app may share the same secret and when keys are rotated they are all restarted collectively.

Before attaching, we need to know the add-on name, it will look something like `securekey-noun-12345`, it was shown earlier when the addon was provisioned.  It can be found later using `aka addons -a [appname-space]`.

To attach the addon to a new app named `newapp-space` run:

```shell
aka addons:attach securekey-noun-12345 -a newapp-space
```

## Rotating Keys

Periodically you may wish to rotate keys, or if one of the keys becomes compromised you can rotate them by using the CLI plugin and executing:

```shell
aka securekey:rotate -a [appname-space]
```

This will restart any apps the addon is attached to as well. 
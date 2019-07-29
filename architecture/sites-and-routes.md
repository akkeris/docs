# Sites and Routes

Akkeris makes it easy to combine multiple application together to form a whole site.  This article shows how to get started with creating a website. 

> Note this document may need some enhancements or reworking.  Feel free to add/remove or modify as necessary.

## Set up

Install the akkeris CLI on your workstation. Sites, certificates and routes can be changed and purchased via the CLI.  To ensure you're ready to go ensure you have the `certs` plugin installed by running `aka plugins:install certs` too.  This adds additional command line tooling to provision certificates should it be necessary. It should be noted that while this article uses the CLI for examples all of these operations can be performed via the UI and the Platform Apps API as well as the CLI.

## Getting Started

This guide takes you through each step in creating a publically available website. Some of these steps may not be necessary and only need to be done once per top-level domain (TLD) and not necessarily for each new site. 

### Purchase a domain 

If you haven't already first you'll need to own the domain you'd like to use.  If you (or someone in your organization) already owns the domain the first step would be to either:

1. Setup the DNS records to point to Akkeris
2. Transfer ownership of the entire domain to Akkeris

The first is relatively simple to accomplish, the second may be more powerful as it allows Akkeris to automatically setup DNS records for you when a site is created.  If the site you want to create is in a domain already transferred to Akkeris than you can skip this step.

### Purchase a TLS Certificate

If you already have a wildcard certificate purchased for your domain you may skip this step. 

Certificates provide encryption for your system, websites require a TLS certificate to state who owns the website.  When creating a certificate there are essentially three types you can purchase:

1. `common` - this is sometimes referred to as ssl plus or ssl/tls certificate. These certificates cover one domain name (such as www.yourdomain.com) and nothing else. 
2. `sans` - this is a certificate that covers both the main domain and up to three other "alternative" names.  This may be useful if you need www.yourdomain.com, www-qa.yourdomain.com, www-dev.yourdomian.com.  The downside of sans is all of the alternative names are viewable by search engines and other systems who reach www.yourdomain.com.
3. `wildcard` - this certificate covers any domain `*.yourdomain.com` regardless of your sub-domain. The downside of wildcards is they are significantly more expensive, and draw additional scrutiny by security experts since they cover so many sub-domains.

You can order and install a common certificate using:

```bash
aka certs:create yourdomain www.yourdomain.com \
  -m 'I need this for my site' -o myorg --region us-seattle
```

To order a SANS certificate specify the common name first, then the alternatives in the -s option, like:

```bash
aka certs:create yourdomain www.yourdomain.com \
  -s www-qa.yourdomain.com -s www-dev.yourdomain.com \
  -m 'I need this for my site' -o myorg --region us-seattle
```

Or to order a wildcard certificate:

```bash
aka certs:create yourdomain \*.yourdomain.com \
  -m 'I need this for my site' -o myorg --region us-seattle
```

> **info**
> Note that it is necessary to escape (with the backslash) the star (astrek) in the `*.yourdomain.com` above as it can be interpreted by shell command utilities as a command.

You will then recieve a prompt with your order information and the price, press "Y" to confirm, and an order will be placed.  At this point a review and approval process will go underway, these usually take a business day or so to provision.

Note that you may purchase a wildcard certificate once and then common certificates to cover more secure/scrutinous portions of your domain as needed.

To check the status of your certificate run:

```
aka certs:status yourdomain
Site: www.yourdomain.com
Expires: 2018-09-01
Status: pending_approval
```

Once the status goes into `approved` you can install it by running:

```
aka certs:install yourdomain
```

### Creating a site

To create a site run:

```bash
aka sites:create www.yourdomain.com
```

This will provision a new site, you should double check that the domain name (in this example `www.yourdomain.com`) is pointing to the correct location and that a certificate for this name (or a sans/wildcard cert that covers it) exists and is installed.

### Create a route

A site by itself does not do much of anything, traffic coming into the site does not yet have a destination, to add one, use routes.  Routes take all or a portion of a site and direct to an application you choose.  You can direct all of the traffic to one application using:

```bash
aka routes:create -s www.yourdomain.com -a yourapp-yourdomain / /
```

This may be all that's needed for most use cases, but in some it may be useful to partition out traffic to different apps based on the URL path, for example, you may want traffic on /api to go to your Ruby API application being developed by team A, then traffic on /dashboard to go to your React UI app being developed by team B.  To do this we can create multiple routes to direct traffic to a specific app based on the path:

```bash
aka routes:create -s www.yourdomain.com -a rubyapiapp-yourdomain /api /
```

This will direct all traffic on https://www.yourdomain.com/api to the app `rubyapiapp-yourdomain` and direct the traffic to `/` at the root of the app.  It's important to note here that we are changing the path as the traffic is routed down to the path from `/api` to `/` so that the app running at `rubyapiapp-yourdomain` will believe the traffic is coming to the root of its http path.  This can be helpful as it allows applications to not have to know what the path is on the website they're being hosted on and thus allows them to be more easily re-used or moved if needed.

You can then add the second route by running:


```bash
aka routes:create -s www.yourdomain.com -a reactdashapp-yourdomain /dashboard /dashboard
```

This again routes traffic on https://www.yourdomain.com/dashboard to the app `reactdashapp-yourdomain`, but unlike the previous example we are not changing the URL.

### Listing Sites

To get a list of sites type `aka sites`.  These sites are all available for apps to place routes into.  See below for more information on adding sites. 

### Steps to Creating a Site

Sites can also be created using `aka sites:create`. 

!!! notice 
    Creating a site with a new domain or product domain require extra steps depending on various factors, see below for what may or may not need to be done. 

First step is to ensure you have the domain name available, any `*.example.io` domain can be immediately used on akkeris. If the domain is outside of those it may require checking the domain is A) owned by your organization and B) the domain name is pointing at akkeris. 

The second step to creating a site is to ensure it has a ssl/tls certificate issued and installed.  Any company domain already has a wildcard ssl/tls certificate.  If you need to provision a new ssl certificate you can order one by running on the command line:

```bash
aka plugins:install certs
```
```bash
aka certs:create short_name www.website.com -m "Comments as to why you need it" -o [organization]
```

The certificate will then go under an infosec review and once approved (generally in a day or two) will be issued, you can check the status of an ssl certificate using:

```bash
aka certs:orders:status short_name
```

Once the certificate has the "issued" status you can install it using:

```bash
aka certs:orders:install short_name
```

Finally, the last step to creating a site is to actually create it in our F5 using the command:

```bash
aka sites:create www.website.com
```


## Routes 

Routes connect a path on a website, to a path on your app.  

### Listing Routes

You can see the current routes on an app by typing `aka routes -s [site]`. For example `aka routes -s abc.example.io` would return the result:

```
→ Route (7b52ed0a-1abc-4ea3-a14c-5651e4c2c46f)	Created: 6/8/2017, 5:34:05 AM
  Pass https://abc.example.io/events/publish/ ➝  https://events-jam-prd.apps.example.io/

→ Route (0cb36d2c-c8e8-4285-b0b3-491a596c23c4)	Created: 6/8/2017, 5:34:22 AM
  Pass https://abc.example.io/events/publish ➝  https://events-jam-prd.apps.example.io/

→ Route (0fd35030-e00c-414c-8335-772034373b03)	Created: 6/8/2017, 5:35:00 AM
  Pass https://abc.example.io/identity/ ➝  https://identity-jam-prd.apps.example.io/

→ Route (f386e005-9524-4343-9557-13766b3b0d1e)	Created: 6/8/2017, 5:35:15 AM
  Pass https://abc.example.io/identity ➝  https://identity-jam-prd.apps.example.io/

→ Route (76bf2801-9a47-4621-bb9f-e9974ec8a2d9)	Created: 6/8/2017, 5:35:42 AM
  Pass https://abc.example.io/users/ ➝  https://users-jam-prd.apps.example.io/

→ Route (5f11ac61-dae4-4331-96ec-4bc67914cd15)	Created: 6/8/2017, 5:35:59 AM
  Pass https://abc.example.io/users ➝  https://users-jam-prd.apps.example.io/

→ Route (d8bdb889-a2c9-4e9e-9b87-88b0183ebd32)	Created: 6/8/2017, 5:56:44 AM
  Pass https://abc.example.io/docs ➝  https://docs-jam-prd.apps.example.io/

→ Route (fc173f41-0b20-4273-bc36-6d4b5f0cf656)	Created: 7/27/2017, 5:43:21 PM
  Pass https://abc.example.io/applications ➝  https://medusa-jam-prd.apps.example.io/applications

→ Route (526a12f2-9e9c-40ba-b225-d7f93caee699)	Created: 7/27/2017, 5:43:21 PM
  Pass https://abc.example.io/customers ➝  https://medusa-jam-prd.apps.example.io/customers

→ Route (77ae5f3f-2f43-4fba-b3e8-c4a3e3eaebf8)	Created: 7/27/2017, 5:43:21 PM
  Pass https://abc.example.io/solutions ➝  https://medusa-jam-prd.apps.example.io/solutions

→ Route (50a2f0fd-5296-490a-918a-0c2fd5d45da9)	Created: 7/27/2017, 5:43:22 PM
  Pass https://abc.example.io/programs ➝  https://medusa-jam-prd.apps.example.io/programs

→ Route (8d87f853-96ca-4f65-9ebd-ef5c0d46f428)	Created: 7/27/2017, 5:43:22 PM
  Pass https://abc.example.io/program-types ➝  https://medusa-jam-prd.apps.example.io/program-types

→ Route (9b189e92-3f96-449c-ac35-666cff5ee046)	Created: 8/15/2017, 11:37:31 AM
  Pass https://abc.example.io/bank/ ➝  https://pointstore-jam-prd.apps.example.io/

```

### Creating Routes

You can also add new routes into a site using `aka routes:create -s [site] -a [app] [/source_path/] [/target_path/]`. 

For example if you wanted to route traffic from `www.somewebsite.com/testing` to your app `myapp-test` at the root path (`/`) you could run `aka routes:create -s www.somewebsite.com -a myapp-test /testing /`.  This would then route all traffic on `www.somewebsite.com/testing` to `myapp-test.apps.example.io/` (and subsequently anything underneath testing such as `www.somewebsite.com/testing/fubar` would go to `myapp-test.apps.example.io/fubar`).

## More Information

See `aka sites --help`, `aka sites:create --help`, `aka routes --help`, `aka routes:create --help` for more info.

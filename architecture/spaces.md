# Spaces

All applications run in a space. Every application may only be in one space.  A space provides mechanisms for service discovery, sets specific types of compliance around how these spaces may conduct themselves and what additional protections or assurances should be provided.

#### Discovery Mechanisms

A space is logical grouping of applications that share the same local network or subnet. This allows applications to communicate between one another using ghost protocols based on ARP and other broadcast mechanisms.  In addition, applications may discover each other via config vars automatically added to their application dynos when they start.  Two config vars are added for each application in the same space, they contain the host and port for where the application may be contacted on its network http port. The config vars are named:

* `APPNAME_SERVICE_HOST`
* `APPNAME_SERVICE_PORT`

Where `APPNAME` is the name of the application \(without the space name\).

#### Compliance and Protections

Applications may require different assurances in their availability, or protections against how they can be changed for auditing and compliance purposes.  They may in addition require protections of how their network ports are accessible.  Compliances can be assigned to a space when its created with the CLI \(`aka spaces:create`\), UI or Platform Apps API \(`POST /spaces`\). Compliances \(by design\) cannot be modified once created.

The following compliances can be set:

* `socs` - When set this keeps audit logs that are sent to admins over email periodically.  Sensitive config vars are redacted within sub-systems as necessary to keep shared secrets safe.  In addition creating builds require a status check on both the source control repository, the app, and the pipeline\(s\) its in before applied.
* `prod` - This protection provides assurance of high availability, any space marked with this compliance will automatically be given preference if resources are limited. This will also forgive certain spikes in application resources.  Finally, production level shared credentials can only be attached to apps in prod spaces. This is a helpful fail safe to protect data and systems.
* `internal` - This protection keeps all network traffic and access to only the internal ingress as defined by network adminstrators.  Applications in spaces that are marked as internal will not be accessible publically.  This provides an additional level of protection to run applications that are only intended to be accessible by internal network users.

#### Logical Groupings

Finally spaces provide a way of grouping applications for a product + environment. All applications in a space will receive a domain name that conatins the space.  Generally, `[appname]-[spacename].[stack].yourdomain.io` or a slight varient of it. Applications can access each one another through these public or \(if internal compliance is set, private\) domain names through https.  The https end point for this domain is automatically routed to the web dyno type on the application through its network as http traffic \(Akkeris at the load balancer level handles encryption and TLS for the app\).  Note that public or private http end points are never provided to anything other than dynos running inside Akkeris.


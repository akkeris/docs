# HTTP/2 and Akkeris

Akkeris supports HTTP/2 by default (regardless if your app is HTTP/1.1 or HTTP/2).  There's specific actions that need to be performed on apps to enable all of the features in HTTP/2. 

## Introduction to HTTP/2

All traffic has the opportunity to upgrade to an HTTP/2 connection via either HTTP/1.1 Upgrade headers or through TLS Encryption and ALPN negotiation (ALPN is a protocol that runs during the encryption handshake). Unless otherwise indicated via the feature `http2-end-to-end`, Akkeris will assume your backend application is running an HTTP/1.1 compatible interface and will not attempt to negotiate an upgrade to HTTP/2 with your backend services.

### HTTP Request Lifecycle

The steps below show how HTTP connections are handled:

1. TLS Encryption is negotiated with the client
2. Using TLS Encryption and ALPN, the client requests either HTTP/1.1 or HTTP/2.
3. The HTTP request is received from the client.
4. The HTTP request may contain an `Upgrade` header to indicate it wants HTTP/2 (even if HTTP/1.1 was requested in the ALPN).
5. Akkeris selects the app to route to based on host and path.
6. Akkeris must determine if backend app is running HTTP/2 or HTTP/1.1.
7. The request is forwarded to destination app unecrypted. If the HTTP versions are different, the requests are converted as needed.

There is a very important aspect to how HTTP connections are handled: Akkeris cannot negotiate with the backend app to see if it supports HTTP/2.

> **danger** Akkeris cannot reliably negotiate HTTP/2 with the backend app as ALPN and TLS are not available. As HTTP/2 can be solely negotiated by some apps via ALPN/TLS Encryption, Akkeris cannot safely determine if a backend application supports HTTP/2 by negotiating with the backend app.

To work around this, the backend app is assumed to be HTTP/1.1 unless otherwise indicated by turning on the `http2-end-to-end` feature on the app (e.g. by running `aka features:enable http2-end-to-end -a [yourapp-space]`). Once this feature is enabled all traffic forwarded back to your application is HTTP/2, even if the requesting client requests HTTP/1.1.  Akkeris automatically handles converting requests where a client requests a HTTP/2 connection and backend supports HTTP/1.1. It also converts between clients requesting an HTTP/1.1 connection and a backend app running on HTTP/2.0.

## Using HTTP/2 End-to-End

While HTTP/2 is down converted to HTTP/1.1 for apps that do not support HTTP/2, by enabling the feature `http2-end-to-end` requests coming in as HTTP/2 will be honored through the entire lifecycle of the request. If the incoming request is HTTP/1.1 and the backend app supports HTTP/2, the request is converted to HTTP/2 automatically by Akkeris. 

Some features of HTTP/2 require a full HTTP/2 end-to-end connection (such as proactively pushing responses to requests you anticipate, or trailing headers). Other features are enabled regardless if `http2-end-to-end` is enabled or not (such as HTTP header compression and connection multiplexing).

If you enable the feature `http2-end-to-end` the app receiving requests cannot negotiate HTTP/1.1 or HTTP/2 via ALPN or upgrade headers. This is sometimes commonly known as "http2 with prior knowledge", "unencrypted HTTP/2 server", "insecure http/2", and sometimes referred to as "http2 without ALPN". 

> **danger** Do not enable ALPN, TLS or secure servers/services in your app while running in Akkeris. Doing so will leave your app unresponsive.

While using HTTP/2 from your localhost may require a TLS certificate that was generated this isn't the case on Akkeris, and your HTTP/2 requests should still remain unencrypted. 

### Node.js HTTP End-to-End Example

```javascript
const http2 = require('http2');

const server = http2.createServer();
server.on('error', (err) => console.error(err));

server.on('stream', (stream, headers) => {
  // stream is a Duplex
  stream.respond({
    'content-type': 'text/html',
    ':status': 200
  });
  stream.end('<h1>Hello World</h1>');
});

server.listen(9000);
```

Important: In this example, the app MUST have `http2-end-to-end` enabled otherwise this app will not be able to receive requests correctly.

## HTTP/2 Question &amp; Answer

#### Why doesn't Akkeris just negotiate with a backend application to see if it supports HTTP/2? Why does it explicitly need to be enabled per app?

HTTP/2 has an unfortunate flaw where negotiation for HTTP/2 can happen through either ALPN/TLS or an upgrade header. Some implementations have indicated they ONLY want to support ALPN or prior knowledge of HTTP/2 (e.g. no negotiation) and not try and negotiate a connection by ugprading an existing HTTP/1.1 request. Since Akkeris cannot know whether the backend app intends to support the HTTP/1.1 `Upgrade` header and it does not implement TLS encryption to backend apps, it must rely on a switch to know if HTTP/2 is available. 

#### Why doesn't Akkeris allow apps to handle TLS encryption?

Encryption is difficult to get right. From apps enabling weak ciphers, supporting out of date TLS protocols (e.g. TLSv1, TLSv1.1, etc), the problematic nature (more a business problems than a technical one) of obtaining certificates, and finally the significant impact of leaked keys are strong reasons for infrastructure to automatically manage encryption for apps. 

In addition, the HTTP connection to the backend app is technically already encrypted. Akkeris hands back what is seen as an unencrypted HTTP connection, but behind the scenes (what's commonly referred to as in transit) the traffic is encrypted in a TCP tunnel with mutual TLS authentication. So the connection is already encrypted.

For these reasons (and a few others) Akkeris chooses to handle encryption for apps to ensure it remains in compliance with security needs and is ubiquitous but transparent to developers. 

#### What HTTP/2 features are supported (and what aren't) if I don't have HTTP/2 support on a backend app?

The following HTTP/2 features are supported regardless if your app supports HTTP/2 or not:

* HTTP/2 header compression
* HTTP/2 connection reuse
* Requests pipelined on connections
* Multiplexing requests on a TCP connection

Features not supported unless your backend app supports HTTP/2:

* Trailing HTTP headers
* HTTP/2 server push
* Opportunistic Responses (pushing responses a server expects to be made soon)
* HTTP/2 "WebSockets"

## HTTP/2 More Information

* [HTTP/2 on Wikipedia](https://en.wikipedia.org/wiki/HTTP/2)
* [Introduction to HTTP/2 by Google](https://developers.google.com/web/fundamentals/performance/http2/)


# URL Parsing

<!-- toc -->

## Introduction

In Akkeris the brokers will return a connection string as a URL, also known as a URI,
see [RFC3986](https://tools.ietf.org/html/rfc3986?).
If an application needs a different format most languages have modules or libraries
that can parse a standard URI. Below are examples, suggestions and references for parsing
a URI.

## Example URI

Postgresql database connection string.

DATABASE_URL="postgres://fakeuser:fakepass@dbhost.somewherein.aws.com:5432/fakedbname?sslmode=disable"

* scheme: postgres
* username: fakeuser
* password: fakepass
* hostname: dbhost.somewherein.aws.com
* port: 5432
* database name: fakedbname
* options: ?sslmode=disable

## Parsing examples by language

### Node

Node has a builtin module for URL Parsing: [URL](https://nodejs.org/dist/latest-v12.x/docs/api/url.html)

```node
const url = require('url')

const myURL = new URL(process.env['DATABASE_URL'])


console.log("protocol:" + myURL.protocol)
console.log("host:" + myURL.host)
console.log("hostname:" + myURL.hostname)
console.log("port:" + myURL.port)
console.log("pathname:" + myURL.pathname)
console.log("search:" + myURL.search)
console.log("username:" + myURL.username)
```

### Javascript

Example from [stackoverflow.com](https://stackoverflow.com/questions/45073320/regex-for-a-url-connection-string)

``` javascript
function url2obj(url) {
    var pattern = /^(?:([^:\/?#\s]+):\/{2})?(?:([^@\/?#\s]+)@)?([^\/?#\s]+)?(?:\/([^?#\s]*))?(?:[?]([^#\s]+))?\S*$/;
    var matches =  url.match(pattern);
    var params = {};
    if (matches[5] != undefined) { 
       matches[5].split('&').map(function(x){
         var a = x.split('=');
         params[a[0]]=a[1];
       });
    }

    return {
        protocol: matches[1],
        user: matches[2] != undefined ? matches[2].split(':')[0] : undefined,
        password: matches[2] != undefined ? matches[2].split(':')[1] : undefined,
        host: matches[3],
        hostname: matches[3] != undefined ? matches[3].split(/:(?=\d+$)/)[0] : undefined,
        port: matches[3] != undefined ? matches[3].split(/:(?=\d+$)/)[1] : undefined,
        segments : matches[4] != undefined ? matches[4].split('/') : undefined,
        params: params
    };
}

console.log(url2obj("protocol://user:password@hostname:12345/segment1/segment2?p1=val1&p2=val2"));
console.log(url2obj("http://hostname"));
console.log(url2obj("?p1=val1"));
console.log(url2obj("ftp://usr:pwd@[FFF::12]:345/testIP6"));
```

### Java/Scala

#### Example from stackoverflow.com

```java
URI uri = new URI("postgres://fakeuser:fakepass@dbhost.somewherein.aws.com:5432/dbname?sslmode=disable");
System.out.println(“Host = ” + uri.getHost());
System.out.println(“Port = ” + uri.getPort());
System.out.println(“Path = ” + uri.getPath());
```

#### Example from spring app

```java
package com.example.config;

import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.sql.DataSource;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;

@Profile({"deploy"})
@Configuration
public class DatabaseConfig {

  @Value("${app.datasource.url}")
  String localUrl;

  public static String[] extractUserNameAndPassword(String url) {
    Pattern regex = Pattern.compile("postgres:\\/\\/(.*):(.*)@(.*)");
    Matcher m = regex.matcher(url);
    if (m.matches()) {
      return new String[] {m.group(1), m.group(2), m.group(3)};
    } else {
      throw new IllegalStateException("Was unable to parse given postgres URL " + url);
    }
  }

  @Bean
  @Primary
  public DataSource localDatasource() {
    String[] urlParts = extractUserNameAndPassword(localUrl);
    return DataSourceBuilder.create()
        .url("jdbc:postgresql://" + urlParts[2])
        .username(urlParts[0])
        .password(urlParts[1])
        .build();
  }
}
```

### Go Language

```go
package main

import  (
  "fmt"
  "os"
  "net/url"
)

func main() {
  u, _ := url.Parse(os.Getenv("DATABASE_URL"))

  fmt.Printf("DATABASE_URL: %s\n", os.Getenv("DATABASE_URL"))
  fmt.Printf("   scheme: %s\n", u.Scheme)
  fmt.Printf("     user: %s\n", u.User)
  fmt.Printf("host:port: %s\n", u.Host)
  fmt.Printf("     path: %s\n", u.Path)
  fmt.Printf("    query: %s\n", u.RawQuery)
}
```

### Ruby

```ruby
require 'uri'

uri = URI.parse(ENV["DATABASE_URL"])
p uri.scheme # postgres
p uri.user
p uri.host
p uri.port
p uri.query

```

### Shell (bsh,zsh,sh)

The postgresql cli(psql) and mysql cli(msql) will accept a url.

```shell
#!/bin/bash

# extract the protocol
proto="$(echo $1 | grep :// | sed -e's,^\(.*://\).*,\1,g')"
# remove the protocol
url="$(echo ${1/$proto/})"
# extract the user (if any)
user="$(echo $url | grep @ | cut -d@ -f1)"
# extract the host and port
hostport="$(echo ${url/$user@/} | cut -d/ -f1)"
# by request host without port
host="$(echo $hostport | sed -e 's,:.*,,g')"
# by request - try to extract the port
port="$(echo $hostport | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')"
# extract the path (if any)
path="$(echo $url | grep / | cut -d/ -f2-)"

echo "url: $url"
echo "  proto: $proto"
echo "  user: $user"
echo "  host: $host"
echo "  port: $port"
echo "  path: $path"
```

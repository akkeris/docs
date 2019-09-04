# Parsing DATABASE_URL returned by database_broker

<!-- toc -->

## Introduction

Some database drivers want the connection url in a different
format than what the database-broker returns in the DATABASE_URL 
environment variable.

EX: DATABASE_URL="postgres://fakeuser:fakepass@dbhost.somewherein.aws.com:5432/dbname?sslmode=disable"

* username: fakeuser
* password: fakepass
* hostname: dbhost.somewherein.aws.com
* port: 5432
* database name: dbname
* options: ?sslmode=disable

## Parsing examples by language

### Node

Npm Module [connection-string-parser](https://www.npmjs.com/package/connection-string-parser)

### Javascript

This was copied from [stackoverflow.com](https://stackoverflow.com/questions/45073320/regex-for-a-url-connection-string)


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
console.log(url2obj(":password@"));
console.log(url2obj("?p1=val1"));
console.log(url2obj("ftp://usr:pwd@[FFF::12]:345/testIP6"));
```

### Java/Scala

Example from stackoverflow.com

```java
URI uri = new URI("postgres://fakeuser:fakepass@dbhost.somewherein.aws.com:5432/dbname?sslmode=disable");
System.out.println(“Port = ” + uri.getPort());
System.out.println(“Host = ” + uri.getHost());
System.out.println(“Path = ” + uri.getPath());
```

### Go Language

### Ruby

### Shell (bsh,zsh,sh)

## Example RegEx


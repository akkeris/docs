# Creating Plugins

Creating plugins allows you to add functionality to appkit (our developer toolkit) independently. The CLI is a great way of adding developer workflows to process as it gives your plugin access to the users git repos, applications and existing environments safely. The CLI also provides mechanisms for updating and managing versions seamlessly.

## Creating your first plugin

1. Create a github repo that is publically accessible (or private if all of the cli users have access to it)
2. At the root of the repo create an "index.js" file
3. Within the index.js file paste this:

```javascript
"use strict"

function some_action(appkit, args) {
  console.log("some action ran!");
}

function other_action(appkit, args) {
  console.log("other action ran!");
}

function fee(appkit, args) {
  console.log("fee ran!");
}

function update() {
    // What do you want to do once the plugin has been updated, 
    // this is executed AFTER the plugin has had the latest set of code
    // pulled, so its a "post" update operation.
}

function init(appkit) {
  // This is fired when the plugin initially loads, 
  // this should not do blocking operations. Here we will add some commands
  // for users and supply the function that will execute when they run.
  appkit.args
    .command('mypluginname', 'list releases on an app', {}, some_action.bind(null, appkit))
    .command('mypluginname:foo', 'some description', {}, other_action.bind(null, appkit))
    .command('mypluginname:fee ID', 'some operation on an id', {'app':{'description':'The app to act on.','string':'true','demand':true}}, fee.bind(null, appkit))
}
module.exports = {
  init,
  update,
  group:'mypluginname',
  help:'manage mypluginname (create, list)',
  primary:true
};
```

## Distributing your plugin 

All developers have to do to install your plugin is type: ```aka install https://github.com/yourrepo/repo```.  Any time they type ```aka update``` your plugin will be auto-updated as well (to whatever is on master).   You can also publish your plugin to a centralized repo for others to explore using `aka plugins:publish`.


## CLI API

Each and every time update or init is run, it comes with an "appkit" object passed in as a parameter with the following properties:

* ```appkit.config``` contains the host, api end points, and plugins directory
* ```appkit.args``` a yargs object where you can add cli commands (see https://http://yargs.js.org/docs/ for more information.)
* ```appkit.plugins``` a hash map of all of the currently installed pluggins
* ```appkit.random_tips``` random tips to display

### Terminal Helpers

Terminal helpers output items in colors using markdown, collect user input or provide common waiting animations to provide a common user interface to users.

* ```appkit.terminal``` a laundry bag of functions to do various terminal stuff (see terminal.js)
* ```appkit.terminal.markdown(text)``` format ### ###, ## ##, ^^ ^^, ~~ ~~, !! !! to colors (blue, gray, yellow, green, red)
* ```appkit.terminal.confirm(text, function(answer) {})``` presents the user with a confirmation and the answer is passed in the callback.
* ```appkit.terminal.input(function(answer) {})``` collects input from the user, once enter is hit the answer is passed in the callback.
* ```appkit.terminal.format_objects(function(object) {}, 'no results text', err, array)``` takes a collection of objects passes them through the formatting function, then runs them through .markdown and prints out the result, if err is defined forward to .error.
* ```appkit.terminal.print(err, anything)``` if err exists, forward to .error, if anything is an object forward to .vtable, if anyting is an array forward to .table
* ```appkit.terminal.vtable(array)``` prints out a vertical table, takes in any object
* ```appkit.terminal.table(object)``` prints out a table, takes in any array with the same object types in the array (the keys in each object become the columns)
* ```appkit.terminal.loader('some text')``` returns an object with two methods "start" and "end", this produces a loading effect with a spinning wheel until end is called.
* ```appkit.terminal.task('some text')``` similar to loader, but end requires either "ok", "warn" or "error" to indicate whether a checkbox, warning symbol or error symbol is produced after the task.
* ```appkit.terminal.error('some text or exception')``` print out a fatal error.

### API Helpers

These API helpers are http methods provided to you to ease communication with Akkeris based API's, they automatically manage content, version and authentication by adding the headers into requests and managing data returned.

Note, see the [Platform Apps API](/architecture/apps-api.md) and the [Auth API](/architecture/auth-api.md) for more information on API end points that can be used.

* ```appkit.api.get(url, function(err, json_returned_object) {})``` the url can be relative (and if so, it will hit the Platform Apps api), automatically adds credentials
* ```appkit.api.delete(url, function(err, json_returned_object) {})``` the url can be relative (and if so, it will hit the Platform Apps api), automatically adds credentials
* ```appkit.api.put(payload_as_string, url, function(err, json_returned_object) {})``` the url can be relative (and if so, it will hit the Platform Apps api), automatically adds credentials
* ```appkit.api.patch(payload_as_string, url, function(err, json_returned_object) {})``` the url can be relative (and if so, it will hit the Platform Apps api), automatically adds credentials
* ```appkit.api.post(payload_as_string, url, function(err, json_returned_object) {})``` the url can be relative (and if so, it will hit the Platform Apps api), automatically adds credentials

### Github API Helpers

The Github API helpers are similar to the API helpers above, but work off of api.github.com and the passed in URL is relative, the github credentials are automatically added. (note certain uri's are restricted such as account operations or organization operations in addition to direct commits). For more information on the end points available see the [Github Developer Guide](https://developer.github.com/).


* ```appkit.github.get(url, function(err, json_returned_object) {})``` the url can be relative (and if so, it will hit the Github api), automatically adds credentials
* ```appkit.github.delete(url, function(err, json_returned_object) {})``` the url can be relative (and if so, it will hit the Github api), automatically adds credentials
* ```appkit.github.put(payload_as_string, url, function(err, json_returned_object) {})``` the url can be relative (and if so, it will hit the Github api), automatically adds credentials
* ```appkit.github.patch(payload_as_string, url, function(err, json_returned_object) {})``` the url can be relative (and if so, it will hit the Github api), automatically adds credentials
* ```appkit.github.post(payload_as_string, url, function(err, json_returned_object) {})``` the url can be relative (and if so, it will hit the Github api), automatically adds credentials

## Publishing your plugin

Use the command line to publish a new plugin: `aka plugins:publish -r [ github repo https uri (without .git) ] -o [your name] -e [your email] -d "Description of the plugin"`. You can also publish a plugin through the Platform Apps API.

## Unpublishing your plugin

You can unpublish your plugin using `aka plugins:unpublish [PLUGIN]`.  Note that unpublishing a plugin will not uninstall it or otherwise make it unavailable to users who have already installed it.  You can also remove plugins through the Platform Apps API.

## Updating your plugin

Updating the master branch of your repository will update your plugin.  Note that your updates will not be seen until users run `aka update`.   To update the metadata on your plugin you can use the `aka plugins:revise` command, or see the Platform Apps API.



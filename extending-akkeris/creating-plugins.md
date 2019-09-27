# Creating Plugins

<!-- toc -->

Akkeris CLI Plugins are powerful ways to automate workflows, perform common routines, or help increase the productivity of other Akkeris users. Some great examples and ideas:

* The postgres plugin pulls the username/password from an app's config and then analyzes performance, blocks, locks, and more to help assist the user in diagnosing database problems (and performance).
* A turnkey way to create an app and repo for an organization that has its security and compliance needs built in.
* Custom scripts to pull down data from production databases, scrub it, then store it in QA databases.

Plugins can be thought of as a javascript module included into the CLI at runtime. There are a few conventions you must follow for your plugin to work.

## What Makes a Plugin

To begin thinking about how plugins work, we'll use the example template below to help walk through some aspects of plugins. You can skip down to a lower section for more information about each aspect. 

At a basic level, each plugin is contained in its own directory. The directory must contain an `index.js` file.  This file is included into the CLI's runtime on start-up. The `index.js` file must export the following:

1. An `init` function which is passed the [akkeris object](creating-plugins.md#the-akkeris-object), its sole duty is to add commands to the cli using `akkeris.args` yargs object. 
2. A `group` property which defines what high-level group the plugin exists in `apps`, `releases`, `sites`, etc.
3. A `help` property to provide a high-level description of the plugin on the help screen.
4. A `primary` property (as a boolean), this indicates whether the plugin is a core service or convenience.

Additionally, an `update` function may be provided, which is passed the [akkeris object](creating-plugins.md#the-akkeris-object) and is executed whenever a user runs `aka update` and after any new source code is pulled from git and after `update.js` is executed [SEEMORE].

```javascript
function supercool_action(akkeris, args) {
  console.log("some action ran, with the arguments:", ${JSON.stringify(args, null, 2))
}

function init(akkeris) {
  akkeris.args
    .command('awesome:supercool', 'This does some super cool action!', {}, supercool_action.bind(null, akkeris))
}

module.exports = {
  init,
  update:() => { /* Do nothing */ },
  group:'awesome',
  help:'My awesome plugin!',
  primary:false,
}
```

The above code would hypothetically be placed in a repository inside an `index.js` file at the root and then could be installed by running `aka plugins:install REPO` (or by publishing it as well). 

In addition to the `index.js` file, the optional files `install.js` and `update.js` can be provided:
- The `install.js` file is included and only executed the first time the user installs the plugin. (see [Installation](#installation) below)
- The `update.js` file is executed whenever the plugin is updated. (see [Updating](#updating) below) 

This is especially useful for initializing and updating npm dependencies, but the sky's the limit!

## Plugin Lifecycle

### Installation

During plugin installation, regardless if installed by name or by a repo path, the following happens:

1. The plugin is cloned down as a git repo into a temporary folder.
2. Once the plugin is cloned, if the `install.js` exists at the root, it is ran (and not exported).
3. If the installation is successful, the `index.js` file is included, and the required exports are checked to ensure there are no obvious problems with the plugin that may cause the CLI to become unstable.
4. Finally, the plugin is moved into `$HOME/.akkeris/plugins/<plugin name>`.

The `install.js` is a great place to install necessary dependencies. For example, if the plugin is built as a npm module, the `install.js` file could add the module's npm dependencies as needed:

```javascript
const proc = require('child_process')
proc.spawnSync('npm', ['install'], {cwd:__dirname, env:process.env, stdio:'ignore'})
```

If at any time during the installation an error occurs, the entire process is backed out, and the plugin folder removed from the users machine.

### Initialization

When a user types any `aka` command, all of the plugins' `index.js` files are immediately included, and their `init` functions called (with the `akkeris` object passed in). Plugins are included and initialized in an asyncronous (and potentially randomized) order. Once initialization is completed, [yargs](https://yargs.org) selects which command to execute, and passes in the arguments for the command to the plugin that handles the command.

During initialization, your plugin should do the following:

* Define the commands the plugin provides using the `akkeris.args` object (the [yargs](https://yargs.org) object)
* Bind the `akkeris` object to any command functions, so you can use it if the command is executed.
* Use the `pluginname:action` convention to define commands. Traditionally, the `pluginname` command would list a resource, or provide general information for the user.

In addition, keep the following in mind during initialization:

* Do not depend on other plugins being initialized during initialization, as the order could be random and is not guaranteed.
* Do not make API calls or other blocking synchronous actions during this phase.
* Do not define or store anything in the `global` or `process` objects.

The `akkeris` object passed into the `init` function contains a property called `args`. This is a [yargs](https://yargs.org) object.  Yargs is a CLI helper tool that you can define commands on. When you define the command with `yargs`, you pass it the expected options, required arguments, description, help, and finally the syncronous or asyncronous function to execute when the command is called.

***Example Init Function***

```javascript
function init(akkeris) {
  akkeris.args
    .command('awesome:supercool', 'This does some super cool action!', {}, supercool_action.bind(null, akkeris))
}
```

### Running

After initialization, [yargs](https://yargs.org) is called to parse the command. Once parsed, the function provided as the callback is executed with the arguments provided by the user as its first parameter. The capabilities of the `akkeris` object may be needed later, if so bind it during the initialization phase to the callback function. 

***Example Binding Callback***

```javascript

function unbound_command(argv) {
  console.log('we cannot use the akkeris object here.')
}

function bound_command(akkeris, argv) {
  console.log('we can use the akkeris object here!', akkeris)
}

function init(akkeris) {
  akkeris.args
    .command('awesome:unbound', 'This calls the unbound functionn!', {}, unbound_command)
    .command('awesome:bound',   'This calls the bound function!',    {}, bound_command.bind(null, akkeris))
}
```

The function called by yargs must fully return and complete its operations. It's free to execute any code as needed, whether asyncronous, syncronous or blocking. Asyncronous functions *are* supported.

Do:

* Use the helper functions on the `akkeris` object to print to the terminal or make api calls.
* Allow all information to be provided on the CLI and optionally ask for it if unavailable. The command should be able to be put into a shell (bash or sh) file and ran without blocking to ask a question.
* For options, use the same common conventions Akkeris commands do. For example, use `--app` with alias `-a` for app, or `-s` and `--space` for space.

Don't:

* Spawn external processes that are disconnected without the explicitly notifying the user.
* Modify contents of files without explicitly notifying (or even better, asking) the user.

### Updating

When a plugin is updated, the following happens:

1. `git pull` is ran in the plugin's root directory.
2. If an `update.js` file is found in the root directory, it is ran (and not exported).
3. If an `update` function is exported by `index.js`, it is called with the `akkeris` object.

The `update.js` file is a great place to install new dependencies that are needed by `index.js` after updating - for example, you can run `npm install` (like the `install.js` example in the [installation](#installation) section).

### Removal

During plugin removal, the plugin is not called (intentionally) and is removed from the filesystem. Should the user reinstall the plugin, no trace of the previous plugin installation is retained.

Don't:

* Store user data, secrets or keys in the plugin's folder. Instead, write to a file in the home directory so that it remains available should the user reinstall the plugin.

## The Akkeris Object

The `akkeris` object is passed in to all plugins' `init` function, and can help with a variety of common CLI and Akkeris tasks.

### Using the Terminal

#### Ask a question

```javascript
akkeris.terminal.question(prompt, cb);
```

Ask a question to the user (the prompt argument), and receive the answer as the first argument in the callback function (`cb`).  For example:

```javascript
akkeris.terminal.question('How old are you?', (answer) => {
  console.log('oh, you are:', answer);
});
```

You can also use promises:

```javascript
let answer = await akkeris.terminal.question('How old are you?')
console.log('oh, you are:', answer)
```

#### Ask a sensitive question (like a password)

```javascript
akkeris.terminal.hidden(prompt, cb);
```

Ask a sensitive question, like what the users password is. The result the user types is not shown. For example:

```javascript
akkeris.terminal.hidden('Password:', (passwd) => {
  // perform login operation
});
```

#### Tell the user to be cautious

```javascript
akkeris.terminal.soft_error(message);
```

This will print a red exclamation followed by your message on the terminal. This is a great way of letting a user know they're about to do something dangerous before prompting for confirmation.

#### Confirm an action

```javascript
akkeris.terminal.confirm(message, cb);
```

Asks the user a yes or no question and returns the result to the callback (`cb`) function. This is usually done prior to destroying a resource.

#### Show a loading prompt

```javascript
loader = akkeris.terminal.task(text);
```

Shows the user `text` then spins a cursor until `loader.end()` is called. This is useful if an operation takes a considerable amount of time as it gives the user the prception the program hasn't crashed. For example:

```javascript
let loader = akkeris.terminal.task('Creating postgres:standard-0 database');
loader.start();
setTimeout(() =>. {
  loader.end('ok');
});
```

Shows the user:

```bash
Creating postgres:standard-0 database... ⣾
```

Where the dots at the end rotate. And on success, eventually shows:

```bash
Creating postgres:standard-0 database... ✓
```

When the loader is finished, use `loader.end('ok')` if everything is successful, and `loader.end('error')` if not. This will display a blue checkmark (✓) or red crossmark (✕) if the operation is ok or errored, respectively.

#### Display an Error

```javascript
akkeris.terminal.error(obj);
```

This displays an error message to the user. The passed in `obj` can be a javascript error, an exception, or a string.

#### Display a Table

```javascript
akkeris.terminal.table(array);
```

Displays an array as a table where each item in the array is an object.  The properties names in the object are used as the column headers.

#### Display an Object

```javascript
akkeris.terminal.vtable(obj);
```

Displays a vertical table or object where the property names are used as the labels.

#### Display Anything

```javascript
akkeris.terminal.print(whatever);
```

Print something to the terminal. If it's a string, it displays the string. If it's an array of objects, it displays a table. If it's an error, it prints an error message. The most convenient of convenience functions.

#### Convert Markdown

```javascript
let stringVal = akkeris.terminal.markdown(input);
```

Parses the `input` string for markdown `**` `***` `##` `###` `^^` `!!` and converts them to colored text, then returns the new converted string back as `stringVal`.  For example:

```javascript
console.log(akkeris.terminal.markdownn(`
## Header ##
!! Loud Warning !!
`));
```

#### Convert a Friendly Date

```javascript
stringVal = akkeris.terminal.friendly_date(dateObj);
```

Converts a date object to a friendly string relative to the current date. For example, a date passed in from 1/10/2019 on 1/11/2019 would produce `1 day ago`.

### Using the Platform and Apps API

The `akkeris` object provides convenience methods to retrieve, update or remove resources from the Platform [Apps API](/architecture/apps-api.md). The API allows you to make any REST based calls to this API without having to know the host or token (it automatically finds the host and handles authentication for you).

#### Making HTTP REST API Calls

You can use `akkeris.api.get` to fetch any relative URI or resource on the platform.  The `get` corresponds to a HTTP VERB, and all other HTTP verbs are available as well (put, patch, delete, head, options).

```javascript
akkeris.api.get('/apps', (error, data) => {
  if(error) {
    return appkit.terminal.error(error);
  }
  appkit.terminal.table(data);
});
```

You can also use promises:


```javascript
try {
  appkit.terminal.table(await akkeris.api.get('/apps');
} catch {
  appkit.terminal.error(error);
}
```

Creating a resource (or using any http verb that requires a payload) can be done by providing a payload:

```javascript
  let app = {"name":"mytestapp", "space":"default", "description":"my test app", "org":"test"};
  let response = akkeris.api.post(JSON.stringify(app), "/apps");
  console.log("Created our first app via a PLUGIN!", response);
```

For more information on what API end points you can retrieve, see the Platform [Apps API](/architecture/apps-api.md) reference.

### Using Yargs

The `akkeris` object contains a [yargs](http://yargs.org) object that manages CLI functionality.  This object allows you to register commands, options, and CLI help during the initalization phase (from the `init` function).  The [yargs](http://yargs.org) object is on `akkeris.args` property.  With this object, you can register commands and their corresponding functions that should be executed when a user requests them in the `init` function.  For example:

```javascript
  async function supercool_action(akkeris, args) {
    console.log('super cool action called with arguments: ', args)
  }

  function init(akkeris) {
    let options = 'app':{
      'alias':'a',
      'demand':true,
      'string':true,
      'description':'The app to do some awesome:supercool action on!'
    };
    akkeris.args
      .command('awesome:supercool SOME_INFO', 'This does some super cool action!', options, supercool_action.bind(null, akkeris))
  }
```

The above example shows how you would register a command `awesome:supercool` on the CLI. When a user runs this command, the function `supercool_action` is called. In addition, before the function is called, yargs will require the user to provide one parameter, and it will populate it in `args.SOME_INFO`. It will also require that the app option is provided with a valid value (because `demand` is set to true in the options).  This will appear as the property `args.app` on the passed in `args` object to the function `supercool_action`. 

For more information on creating commands and using options, see the [yargs](http://yargs.org) documentation.

## Debugging and Development Tips

You can debug a CLI command by setting the environment variable `DEBUG=true`. This will print out all of the http requests made through the Akkeris API and show more detailed stack trace errors (rather than friendly error message normally shown).

During development, it may be tedious to push your changes to a repository then uninstall and re-install a plugin to test it. To make development more convenient, install your plugin, then symlink your installed plugin to your development directory (it does a git clone so you'll already have git conveniently available). For example, if your plugin was named `myplugin` and you wanted to actively develop on it in a folder `~/Projects/myplugin`, you could first install the plugin with `aka plugins:install REPO`. Once installed, run

```shell
ln -s ~/.akkeris/plugins/myplugin ~/Projects/myplugin
```

Note: On Windows you can browse to your home directory and go to the `.akkeris` folder then `plugins` folder and find your plugin there.

Then work locally on `~/Projects/myplugin` and all of your changes will immediately be available locally. 

## How To: Creating Your First Plugin

Before starting this how to, you should be familiar with the following concepts:

1. Understand node.js development and javascript.
2. Have aka installed with it connected up and logged in to Akkeris.
3. Understand Git and Git workflows.
4. Understand basic HTTP REST API concepts.
5. Have reviewed the [Apps API](/architecture/apps-api.md) reference.
6. Are comfortable with the CLI or shell.

In this exercise, we'll pull a list of applications on Akkeris, filter only the spaces `foo` and `bar`, and print them out to the terminal. We'll call this plugin 'myapps'.

### Create a Repository

You should name the repository `myapps`, or if you chose a different name for the plugin, make sure the repo is similar in name. 

Clone out your empty repo and create the following empty files:

```
myapps
 `- index.js
 `- README.md
```

### Create a Basic Command

Populate the index.js with the following code:

**index.js**
```javascript
async function myapps(akkeris, args) {
  let apps = await akkeris.api.get('/apps'); // fetch all of the apps
  apps = apps.filter((app) => app.space.name === 'foo' || app.space.name === 'bar') // filter ours
  apps.forEach((app) => {
    console.log(`${app.key} (id: ${app.id})`); // print them out.
  })
}

function init(akkeris) {
  akkeris.args
    .command('myapps', 'List out apps in foo and bar spaces', {}, myapps.bind(null, akkeris))
}

module.exports = {
  init,
  update:() => { /* Do nothing */ },
  group:'myapps',
  help:'Manages my applications',
  primary:false,
}
```

Populate the README.md with the following markdown:

```markdown
# My Apps Plugin

My apps plugin description
```

### Setup Your Environment

Once you have the `index.js` code populated, push it up to your repository. You can then setup your environment so that you can iterate on the plugin locally by first installing the plugin, then linking the installed code (with the cloned git repository) to a location more convenient in your workspace. 

Start by installing the plugin:

```shell
aka plugins:install REPO
```

Once you're finished pick a location in your workspace (for example `$HOME/Projects/myapps`). Then link the `myapps` plugin to the location in your workspace. For example:

```shell
ln -s $HOME/.akkeris/myapps $HOME/Projects/myapps
```

You can now iterate on the plugin and add new functionality in your workspace without needing to uninstall and reinstall the plugin to see new functionality. 

Congratulations! You've created your first plugin. 

### Next Steps

* [Publish Your Plugin](/architecture/plugins.md#Publishing-and-Revising-a-Plugin)
* Read more about the [Apps API](/architecture/apps-api.md).
* See the [Postgres Plugin](https://github.com/akkeris/cli-pg-plugin) for inspiration.



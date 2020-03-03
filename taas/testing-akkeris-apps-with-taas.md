# Tutorial: Testing Akkeris Apps with TaaS

This tutorial will walk you through the process of testing an app with Taas.

We will create a test suite, configure a new Taas test, and trigger that test.

## Prerequisites

**Akkeris App**
   
To keep the scope of this tutorial focused on Taas, we're going to assume that you have a running Akkeris app that responds to HTTP requests. If you are unsure on how to do this, see the main Akkeris docs for help.

**Akkeris CLI**

The Akkeris CLI must be installed on your machine. Install [Node.js](https://nodejs.org/en/) and [npm](www.npmjs.com/get-npm), then run:

`$ npm install -g akkeris`

**Akkeris CLI Taas Plugin**

Install the Taas plugin for the CLI:

`$ aka plugins:install taas`

## Create Test Suite

Let's create a simple test suite to test our Akkeris app. You can either follow along below, or just clone the code from [the Github repo](https://github.com/akkeris/taas-tutorial) and skip to [Deploy to Akkeris](#deploy-to-akkeris).

### Test Suite Structure

Create a new directory with the following files in it:

#### index.js
This is the guts of our test suite. Essentially, it attempts to get an HTTP reponse from a URL. If the status is OK (e.g. 200), it returns 0. If it's not OK (e.g. 401), it returns 1. Pretty simple!

```javascript
// Easy to use HTTP request library
const axios = require('axios');

// Get URL to target from an environment variable, using Google as a fallback
const targetURL = process.env.TARGET_URL || "https://google.com/"

async function test() {
  try {
    console.log(`Testing ${targetURL}...`)
    // Make an HTTP request to the target URL
    await axios.get(targetURL);
    console.log("Test passed!")
    // If we reach this point, we got an OK response and can return 0 (success)
    process.exit(0)
  } catch (err) {
    // The status of the response was not in the OK range (200).
    if (err.response && err.response.status && (err.response.status < 200 || err.response.status > 299)) {
      console.log(`Response code out of expected range: ${err.response.status}`)
    // Something else bad happened...
    } else {
      console.log(err.message)
    }
    console.log('Test failed!')
    // If we reach this point, we did not get an OK response and need to return 1 (failure)
    process.exit(1)
  }
}

// Sleep for 5 minutes if PORT is set
// This will allow the Akkeris release to be successful
if (process.env.PORT) {
  setTimeout(() => console.log('Sleepy'), 300000)
}

// If FAIL is set, immediately fail. 
// This is useful for testing.
if (process.env.FAIL) {
  process.exit(1);
}

test();
```

#### package.json
This file lists our app's npm dependencies.

```json
{
  "name": "simple-app",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "axios": "^0.19.0"
  }
}

```

#### Dockerfile
This file provides instructions to Docker on how to build our app into an image.

```dockerfile
FROM node:12-alpine
WORKDIR /src/app
COPY index.js package.json /src/app/
RUN npm install
CMD ["npm", "start"]
```

#### .gitignore
This will make sure we don't check any dependency runtime files into our Git repo.

```
node_modules 
```

### Deploy to Akkeris
Now we need to deploy our test suite as an Akkeris app. There's a few ways to do this, but the easiest for our purposes is to create a new Github repository and link it to a new Akkeris app.

#### Create Git Repository
Create a new repository on Github, then initialize and add the project's structure to an local repo. Then, push it to Github.

(If you cloned the sample code, first run `$ rm -rf .git` in the code directory)

```shell
git init
git remote add origin https://github.com/ORG/REPO
git add Dockerfile index.js package.json
git commit -m "first commit"
git push -u origin master
```

Now, create an access token so Akkeris can access it (optional if admin user is authorized in the repo):
- Go to https://github.com/settings/tokens/new
- Fill out the form, making sure to select the `repo` and `admin:repo_hook` settings. Then select "Generate Token"
- Copy the new token and save it for later use


#### Create and Link Akkeris App
Let's use the Akkeris CLI to create a new app and link it to our Git repository. 

```shell
aka apps:create simplesuite -s SPACE -o ORG -d "Simple Taas test suite for testing Akkeris apps"
aka repo:set -a simplesuite-SPACE https://github.com/ORG/REPO -u USERNAME -t TOKEN
```

There is an important difference here between deploying the test suite and a regular Akkeris app - we don't actually want to have any dynos running for the test suite! Wait a minute or so for the app to be released, and scale the web dyno to 0:

```shell
aka ps:scale -a simplesuite-SPACE web=0
```

Hooray - our test suite is ready to be used in Taas! When we make changes to our test suite in Github, it will be automatically built by Akkeris and be ready to use in the next test run.

## Taas Test Setup

Now that we have our test suite up in Akkeris, let's create a Taas test:

`$ akm taas:tests:register`

This will prompt you for all the information that Taas needs in order to set up a new test. (See [Registering Tests](registering-tests.md) for more detailed information)

Proceed through the prompts, using the following table as a guide:

| Question                          | Example Answer        | Notes                                                                                 |
| --------------------------------- | --------------------- | ------------------------------------------------------------------------------------- |
| Select an App                     | `testapp-default`     | The name of the app that will be tested                                               | 
| Do you want to test preview apps? | `no`                  | Preview apps are not covered by this tutorial                                         |
| Test Name                         | `tutorial`            | This is what your test will be called                                                 |
| Test Space                        | `taas`                | This is where the test suite will run, normally choose `taas`                         |
| Is test suite an Akkeris app?     | `yes`                 | We've made our test suite an Akkeris app, so choose "yes"!                            |
| Select the test suite app         | `simplesuite-SPACE`   | Choose the app that you created for our test suite                                    |
| Override command in docker image? | `no`                  | Command override is not covered in this tutorial                                      |
| Automatically promote?            | `no`                  | Pipeline promotion is not covered in this tutorial                                    |
| Timeout                           | `60`                  | How many seconds do you want to wait before the test is considered to have timed out? |
| Start Delay                       | `1`                   | How many seconds do you want to wait before starting the test?                        |
| Slack Channel                     | `@yourslackname`      | Where do you want to be notified of test results? (optional)                          |
| Environment Variables             | `TARGET_URL=[appurl]` | Replace appurl with the URL of your Akkeris app                                       |

Your Taas test is now ready to roll!

## Triggering Your Test

To kick off your test suite, run:

`$ akm taas:tests:trigger tutorial-taas` (replace tutorial-taas with your test name if you named it something different)

Soon the results of test will be sent to your specified slack channel!

<img width="400" alt="Test Results" src="https://user-images.githubusercontent.com/28632549/71924150-a8a64a80-314b-11ea-8cf8-329195564ef0.png">

Don't have Slack? You can use the CLI to see results:

`$ akm taas:tests:runs tutorial-taas`

Copy the `runid`. Then, you can get detailed information with one of these commands:

`$ akm taas:runs:info [RUNID]` - See general information about the run

`$ akm taas:runs:output [RUNID]` - See logs for the run

`$ akm taas:runs:artifacts [RUNID]` - See artifacts (screenshots, Kubernetes info) for the run

`$ akm taas:runs:rerun [RUNID]` - Redo the run

## Further Reading

To find out how to use Taas with pipeline status checks, check out the [TaaS Pipeline Status Checks Tutorial](pipeline-status-checks-with-taas.md)
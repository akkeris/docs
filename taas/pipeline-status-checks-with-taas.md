# Tutorial: Pipeline Status Checks with TaaS

## Prerequisites

If you aren't familiar with Taas, you might want to first read the [Testing Akkeris Apps with TaaS Tutorial](testing-akkeris-apps-with-taas.md)

We will assume for the purposes of this tutorial that you have an Akkeris app, a test suite in Akkeris, and a Taas test registered. If you don't have these things, you can follow the [Tutorial](testing-akkeris-apps-with-taas.md) to get them set up.

Make sure your Akkeris app has been tested previously by Taas and the test passed (if you followed the tutorial, you're ready!)

## Pipeline Status Checks Overview

Pipeline status checks let you get more information on the status of each app in an Akkeris pipeline. You can then choose to require that an app have a certain status before it is allowed to be promoted to the next pipeline stage.

When an app is tested with Taas, Taas will report the status of the test (pass/fail) to the associated Akkeris release.

![Successful Release](https://user-images.githubusercontent.com/28632549/71930082-2b350700-3158-11ea-9c46-8628d3633675.png)

That status can then be used in a pipeline for promotion control.

## Pipeline Setup

### Creating a Pipeline

Let's create a pipeline so we can see how the process works.

You can use either the UI or CLI for this, but pipelines are a lot easier to understand in the UI. Navigate to the Pipelines page and click the "plus" icon in the top right to create a new pipeline. Give it a name (e.g. "tutorial"), and click "Finish".

### Adding Apps

Now, let's add some apps to the pipeline. Add a new app to the Development stage by clicking the "plus" icon next to "Development".

Search for the name of your test app and click "OK".

![New Development App](https://user-images.githubusercontent.com/28632549/71930195-6cc5b200-3158-11ea-9787-c2073772a3d5.png)

Great - your Taas-targeted app is now in the Development phase! 

![App In Development Stage](https://user-images.githubusercontent.com/28632549/71930250-8666f980-3158-11ea-8d6e-0718716807eb.png)

Since you have tested your app with Taas previously, you can see that the recent release has a "Tests Passed!" status attached by Taas.

![Development App Recent Release](https://user-images.githubusercontent.com/28632549/71930293-9b438d00-3158-11ea-8eb7-834634ffda41.png)

Let's make a new "staging" app that we can promote our "dev" app to. You can create this app via the CLI or UI, and name it whatever you wish.

e.g. `$ aka apps:create simplestg -s SPACE -o ORG -d "Staging app for Taas tutorial"`

Now, let's add it to our pipeline. Click the "plus" icon next to Staging, and search for the name of your test app. 

As you can see, the Taas status check is available! Click the checkbox to enable the status check, and click OK.

![Adding Staging App](https://user-images.githubusercontent.com/28632549/71930330-ac8c9980-3158-11ea-962b-5f5ccbaf59b1.png)

Our pipeline is now complete!

![Complete Pipeline](https://user-images.githubusercontent.com/28632549/71930361-ba421f00-3158-11ea-821f-2d97b4f8f19d.png)

## Testing Status Checks

### Successful Status

Let's make sure our status checks work. Click the "Promote" button on your Development app and see what happens!

![Promotion Prompt](https://user-images.githubusercontent.com/28632549/71930496-02614180-3159-11ea-9df4-3b1328063ad7.png)

As you can see, Taas has reported a successful status, and we are allowed to promote the app. Clicking OK will promote the app to the Staging stage, and a new release will be created on that app.

![After Promotion](https://user-images.githubusercontent.com/28632549/71930522-1147f400-3159-11ea-887e-898dad2c92c6.png)

### Unsuccessful Status

What if our development app failed its test? Let's find out!

Remember that bit of code in our test suite from the tutorial that would automatically fail a test if an environment variable was set?

```javascript
// If FAIL is set, immediately fail. 
// This is useful for testing.
if (process.env.FAIL) {
  process.exit(1);
}
```

Let's put it to use. Add the `FAIL` environment variable to your Taas test and trigger it.

`$ aka taas:config:set tutorial-taas FAIL=true`

`$ aka taas:tests:trigger tutorial-taas`

Once the results roll in, you'll see that (unsurprisingly) the test failed. Taas will then report the status as "failed" in the latest release:

![Failed Status](https://user-images.githubusercontent.com/28632549/71930539-1e64e300-3159-11ea-83f6-58be45f5bc87.png)

Now, go ahead and try to promote your app:

![Promotion Blocked](https://user-images.githubusercontent.com/28632549/71930558-26248780-3159-11ea-9770-bb2fe16f9a75.png)

As you can see, promotion has been blocked due to our Taas tests failing. If you have elevated access, you can bypass the warning, but it's not recommended. 

Our status checks worked! If you remove the `FAIL` environment variable from the test and re run the test, promotion will be available again.

`$ aka taas:config:unset tutorial-taas FAIL`

`$ aka taas:tests:trigger tutorial-taas`

## Automatic Promotion

If you don't like checking if the test has passed and then manually clicking "promote", Taas can automate pipeline promotions! 

Let's edit our Taas test to enable this feature. Replace `tutorial-taas` with your Taas test name if necessary.

`$ aka taas:tests:update tutorial-taas -p pipelinename -v [PIPELINE NAME]`

`$ aka taas:tests:update tutorial-taas -p transitionfrom -v development:[DEV APP NAME]`

`$ aka taas:tests:update tutorial-taas -p transitionto -v staging:[STG APP NAME]`

## Successful Status

Let's kick off a new successful test! 

_Hint: did you remember to remove the `FAIL` environment variable?_

`$ aka taas:tests:trigger tutorial-taas`

If you have Slack notifications set up, you'll see the result of your automated promotion.

<img width="750" alt="Automatic Promotion Slack" src="https://user-images.githubusercontent.com/28632549/71930579-33417680-3159-11ea-9d15-ceae77f845c9.png">

If you check your pipeline, you'll see that the promotion and deployment was successful. Hooray!

## Unsuccessful Status

Let's add that `FAIL` environment variable back in so we can see what happens when tests fail.

`$ aka taas:config:set tutorial-taas FAIL=true`

`$ aka taas:tests:trigger tutorial-taas`

If you have Slack notifications set up, you'll see the result of your automated promotion there.

<img width="455" alt="Slack Promotion Failed" src="https://user-images.githubusercontent.com/28632549/71930614-42282900-3159-11ea-85c2-de7a7656562c.png">

As you can see, the test result was "failed", so no automatic promotion took place. If you go to the pipeline, you'll see a failed status in the Development stage, and promoting will be blocked.

![Status Fail](https://user-images.githubusercontent.com/28632549/71930642-4eac8180-3159-11ea-98e8-449a2e0d1412.png)

## Next Steps

This isn't the end - you can actually chain _multiple_ Taas tests and have your entire pipeline be tested and promoted in each environment from Review to Promotion when your app is released! See [Promoting Apps with TaaS](promoting-apps-with-taas.md) for more information.
## Preparation

- The Akkeris CLI must be installed on your machine
  - Install [Node.js](https://nodejs.org/en/) and [npm](www.npmjs.com/get-npm)
  - `$ npm install -g akkeris`
- If you already have the Akkeris CLI, update it:
  - `$ aka update`
- Have the app's details on hand before you begin
  - `$ aka apps:info -a myapp-dev`
- Install the Akkeris TaaS plugin
  - `$ aka plugins:install taas`

## Registering a New Test

During test registration, you will be prompted for a few details:

- ? Select an App:
  - Akkeris app that will be targeted by the test
- ? Test Name:
  - Name of the new test
- ? Test Space:
  - Space to run the test in (normally `taas`)
- ? Is test suite an Akkeris app? (Y/N)
  - IF YES, test will run the image associated with an Akkeris app.
    - ? Select the test suite app:
  - IF NO, test will run a user-specified image
    - ? Provide image location:
- ? Override command in docker image  (Y/N)
  - IF YES, test will use a custom Docker command
    - ? Command:
  - IF NO, test will use the default command in the image
- ? Automatically promote? (Y/N)
  - IF YES, test will promote target app in an Akkeris pipeline if the test succeeds
    - ? Pipeline Name:
    - ? Transition From:
    - ? Transition To:
  - IF NO, no promotion will be made (select this if you are unsure)
- ? Timeout:
  - How long the test will run before timing out
- ? Start Delay:
  - How long the test will wait before running after being triggered
- ? Slack Channel:
  - Which Slack channel should the results of the test be posted to?
- ? Environment Variables:
  - Specify any environment variables that the test should have

Once you have decided on the details of your new test, go ahead and run the test registration command. The CLI will prompt you for the required information.
`$ aka taas:register`

## Verifying Test Information

Once your test is created, you can verify that your test was registered and all of the details are correct:
`$ aka taas`
`$ aka taas:info testname`

If you need to add additional variables:
`$ aka taas:config:set testname KEY=value`

If you need to add secrets to the test:
`$ aka taas:secret:create testname -p planname`

For more information on any of these commands, you can use the `--help` option:
`$ aka taas:config:set --help`

You can also see a list of all possible taas commands:
`$ aka help taas`

## Triggering a Test

To start running a test:
`$ aka taas:trigger testname`

To view logs for a test:
`$ aka taas:logs testname`

Once the test is completed, your designated Slack channel will have received the results of the test. A few helpful links are included in these results:
- Logs: link to raw log data from Akkeris
- Kibana: link to pretty and searchable log data
- Rerun: link that will re run the test
- Commit: link to the last commit on Github prior to merge
- Artifacts: any files that were uploaded to the TaaS S3 bucket during the test

If you enabled pipeline auto-promotion, the app will be promoted according to the test settings (provided external status checks have passed). If a test is configured to run on that environment, it will automatically be triggered (see [Promoting Apps with TaaS](promoting-apps-with-taas.md))

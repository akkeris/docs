# Best Practices and Guidelines

## Table of Contents

<!-- toc -->

## Introduction

This guide is intended to help you get the most out of using Akkeris and as a guideline if you intend to contribute to it.

> While developing a new project is like a rolling green field to you, maintaining one is a dark twisted cold swamp for someone else. 

It's because of this we have a few guidelines and best practices while programming to help you create projects that are easy to maintain for others. This is not a bible, and all rules are meant to be broken, but we have justifications for each decision and hope you'll consider them closely (and adopt them).

- [Platform](#platform)
- [Git](#git)
    - [Some Git rules](#some-git-rules)
    - [Git workflow](#git-workflow)
    - [Writing good commit messages](#writing-good-commit-messages)
- [Documentation](#documentation)
- [Environments](#environments)
    - [Consistent dev environments](#consistent-dev-environments)
    - [Consistent dependencies](#consistent-dependencies)
- [Dependencies](#dependencies)
- [Self-Service](#selfservice)
- [Testing](#testing)
- [Structure and Naming](#structure-and-naming)
- [Code style](#code-style)
    - [Some code style guidelines](#code-style-check)
    - [Enforcing code style standards](#enforcing-code-style-standards)
- [Logging](#logging)
- [API](#api)
    - [API design](#api-design)
    - [API security](#api-security)
    - [API documentation](#api-documentation)
- [Performance](#performance)
- [Resources](#resources)
- [Licesning](#licensing)

<a name="platform"></a>
## 0. Platform and Design
![Platform](images/modules.png)

> Consider following the twelve factor manifesto when designing your app to make it portable, scalable and reslient. [read the twelve factors](https://www.12factor.net)

### 0.1 Filesystems

* Do not write to the file system, store data in a resource (such as S3, database)

    _Why:_
    > Writing to the file system causes security issues, data retention/process issues, performance problems, and difficulty recovering from errors.  [read more](filesystems.md)

### 0.2 Sticky Sessions

* Do not use sticky sessions. Sticky sessions are systems or apps that require requests from the same user or client to go to the same server.  

    _Why:_
    > Load balancers must keep track of servers and route them, and this has overhead. During deployments a server cannot be deployed to until all users on it are finished. In addition, if a server becomes overloaded, scaling up the amount of servers will not help the overloaded server. Instead of using sticky sessions, you should allow a user or client to go to any server hosting your app and store session data in a redis or other key store data and pull it from redis based on the id in a session cookie.


### 0.3 Seperate your code, config and data

* Never store configuration, even a hardcoded URL in your code (e.g., store config in your code)

    _Why:_
    > Your code should be deployable to any environment, putting environment configuration in your code locks the code to only that environment and makes it less flexable. Config should be stored in your apps environment on the platform.

* Never store configuration in your database (e.g, store config with your data)

    _Why:_
    > It makes it difficult to know where configuration is stored. In addition if production data is copied or refreshed to QA the applications running may accidently start communicating with production (or fail).  It causes many confusing issues that should be avoided.
 
* Never store code in your database (e.g., code in your data, this happens in ETL products)

    _Why:_
    > It makes it impossible to pull back your data from prod to qa without also pulling back your code.  It makes rolling back code more difficult if its tied to data that has changed.

* Never store data in your code (this can happen with novices)

    _Why:_
    > Data may not be appropriate for an environment. And code could be on any environment. Data may have security/compliance needs that its inappropriate to store with code.  Finally, data cannot be written or modified with code without re-creating a deploy. 

### 0.4 Seperate your builds from a release from a run

* Never conduct build actions on startup, these should be done once

    _Why:_
    > Being quick to startup and quick to shut down is critical for an application to scale quickly. In addition, conducting build steps at runtime opens the door for variences in the program between different boots.

* Seperate your run vs your release

    _Why:_
    > A release should indicate the first time a peice of code is ran on an environment (or a change in the code running in an environment, even a rollback).  A run may be one specific server starting your code.  If you need to conduct a one-off task like database migrations, these should occur only at release and not on a run.

* Releases and builds are ALWAYS effemeral. 

    _Why:_
    > The release history may not be modified as it will only cause confusion, for example a rollback in a platform should first have the release of the image then a new release indicating a rollback to a previous image.  This is critical as it allows things like database schemas to also be rolled back and indicates (with the new release) an opportunity to reverse state or change the state of a system.  It's also just good house keeping.


* Builds should produce an image thats then promoted between environments

   _Why:_
    > Seperate builds for each environment introduces the opportunity for errors or inconsistencies. Your development enivonment should produce an image that cannot be modified but moved up to your qa, staging etc without modification or re-build.


### Treat your logs as streams

* Your app should write its logs to stdout and stderr, platforms should stream your logs to any syslogd end point on request.

    _Why:_
    > Logs stored on the file system violate the file system rule. Also, it allows your logs to be sent to multiple different systems for analysis and storage.  It also simplifies getting information out from your app.

<a name="git"></a>
## 1. Git
![Git](images/branching.png)
<a name="some-git-rules"></a>

### 1.1 Some Git rules
There are a set of rules to keep in mind:

* Perform work in a feature branch.
    
    _Why:_
    >Because this way all work is done in isolation on a dedicated branch rather than the main branch. It allows you to submit multiple pull requests without confusion. You can iterate without polluting the master branch with potentially unstable, unfinished code. [read more...](https://www.atlassian.com/git/tutorials/comparing-workflows#feature-branch-workflow)
* Branch out from `master` (or whatever your main branch is)
    
    _Why:_
    >This way, you can make sure that code in master will almost always build without problems, and can be mostly used directly for releases (this might be overkill for some projects).

* Never push into `master` branch. Make a Pull Request.
    
    _Why:_
    > It notifies team members that they have completed a feature. It also enables easy peer-review of the code and dedicates forum for discussing the proposed feature.

* Update your local `master` branch and do an interactive rebase before pushing your feature and making a Pull Request.

    _Why:_
    > Rebasing will merge in the requested branch (`master` or whatever is your main branch) and apply the commits that you have made locally to the top of the history **without** creating a merge commit (assuming there were no conflicts). Resulting in a nice and clean history. [read more ...](https://www.atlassian.com/git/tutorials/merging-vs-rebasing)

* Resolve potential conflicts while rebasing and before making a Pull Request.
* Delete local and remote feature branches after merging.
    
    _Why:_
    > It will clutter up your list of branches with dead branches. It insures you only ever merge the branch back into (`master` or whatever is your main branch) once. Feature branches should only exist while the work is still in progress.

* Before making a Pull Request, make sure your feature branch builds successfully and passes all tests (including code style checks).
    
    _Why:_
    > You are about to add your code to a stable branch. If your feature-branch tests fail, there is a high chance that your destination branch build will fail too. Additionally, you need to apply code style check before making a Pull Request. It aids readability and reduces the chance of formatting fixes being mingled in with actual changes.

* Use [this](./.gitignore) `.gitignore` file.
    
    _Why:_
    > It already has a list of system files that should not be sent with your code into a remote repository. In addition, it excludes setting folders and files for most used editors, as well as most common dependency folders.

* Do not commit environment files (`.env`), even for dev
    
    _Why:_
    > Environment configuration's "sources of truth" is the config for that running app, having two locations that store the configuration (git and the environment) makes it more likely for errors to crop up. In addition some environments or env files can still contain sensitive information that should never be stored in git. 
    > In your local dev startup script use: `aka config -a [dev-app] -s > .env ; source .env` This will allow you to always use the configuration that's on your dev apps and allows users to immediately get started without having to do anything.

* Protect your `master` branch (or whatever is your main branch).
  
    _Why:_
    > It protects your production-ready branches from receiving unexpected and irreversible changes. It also is required by our compliance and security for SOCS apps. read more... [Github](https://help.github.com/articles/about-protected-branches/) and [Bitbucket](https://confluence.atlassian.com/bitbucketserver/using-branch-permissions-776639807.html)

* Require your `master` branch or other protected branches have a review and approval before merging.


    _Why:_
    > Part of our SOCS compliance insists all changes to our code base for product related applications have been peer reviewed, plus peer review is great way for others to help catch bugs before they enter our main code branches. 


* Include your project management ticket number in the name of the Pull Request. For most teams this is JIRA. 
  
    _Why:_
    > Part of our SOCS compliance insists all changes to our code base for product related applications have a reference to what the original request was and who requested it (which is managed in JIRA). So adding the ticket to the PR allows us to more easily associate the request with what was done. 


* Don't use long lived branches for releases (e.g., dev, qa, prod), instead use pipelines.
  
    _Why:_
    > Long lived branches allow flexibility in what code may go into a specific environment, but they promote poor code hygine.
    >
    > 1. Env configuration may be stored in a branch which couples the code with its configuration.  
    > 2. It causes back-filled merges, e.g., commits in `prod` that have to be backfilled to `dev` and `qa`.  
    > 3. Feature branches (if accidently merged into both `dev` and `qa`) create two commits, and conflict. 
    > 4. Auditing becomes more complex because commits/merges are also releases (e.g., `dev` -> `qa` merge may not have a ticket). 
    > 5. Allows code to exist that has not been through `qa` environment into production as each branch could contain cherry-picked commits due to the previous issues.
    >
    >
    > Using pipelines will take the exact image on dev, then push it to qa, then production.  
    > 
    > If you're finding your code has many things that are not ready to go to QA when you want to promote your image, it may be a good sign its time to split up your app into two apps, or that a feature branch was not truly ready to be merged (or should be contained in production using feature flags).



<a name="git-workflow"></a>
### 1.2 Git workflow
Because of most of the reasons above, we'd like to use [Feature-branch-workflow](https://www.atlassian.com/git/tutorials/comparing-workflows#feature-branch-workflow) with [Interactive Rebasing](https://www.atlassian.com/git/tutorials/merging-vs-rebasing#the-golden-rule-of-rebasing) and some elements of [Gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows#gitflow-workflow) (naming and having a master branch). The main steps are as follows:

* For a new project, initialize a git repository in the project directory. __For subsequent features/changes this step should be ignored__.
   ```sh
   cd <project directory>
   git init
   ```

* Checkout a new feature/bug-fix branch.
    ```sh
    git checkout -b <branchname>
    ```
* Make Changes.
    ```sh
    git add
    git commit -a
    ```
    _Why:_
    > `git commit -a` will start an editor which lets you separate the subject from the body. Read more about it in *section 1.3*.

* Sync with remote to get changes you’ve missed.
    ```sh
    git checkout master
    git pull
    ```
    
    _Why:_
    > This will give you a chance to deal with conflicts on your machine while rebasing(later) rather than creating a Pull Request that contains conflicts.
    
* Update your feature branch with latest changes from master by interactive rebase.
    ```sh
    git checkout <branchname>
    git rebase -i --autosquash master
    ```
    
    _Why:_
    > You can use --autosquash to squash all your commits to a single commit. Nobody wants many commits for a single feature in master branch. [read more...](https://robots.thoughtbot.com/autosquashing-git-commits)
    
* If you don’t have conflicts, skip this step. If you have conflicts, [resolve them](https://help.github.com/articles/resolving-a-merge-conflict-using-the-command-line/)  and continue rebase.
    ```sh
    git add <file1> <file2> ...
    git rebase --continue
    ```
* Push your branch. Rebase will change history, so you'll have to use `-f` to force changes into the remote branch. If someone else is working on your branch, use the less destructive `--force-with-lease`.
    ```sh
    git push -f
    ```
    
    _Why:_
    > When you do a rebase, you are changing the history on your feature branch. As a result, Git will reject normal `git push`. Instead, you'll need to use the -f or --force flag. [read more...](https://developer.atlassian.com/blog/2015/04/force-with-lease/)
    
    
* Make a Pull Request.
* Your pull request should include a JIRA ticket name [PROJECT]-[NUMBER]. e.g, VP-1013 (for the Victories project VP, and ticket 1013).
* Pull request will be accepted, merged and close by a reviewer.
* Remove your local feature branch if you're done.

  ```sh
  git branch -d <branchname>
  ```
  to remove all branches which are no longer on remote
  ```sh
  git fetch -p && for branch in `git branch -vv | grep ': gone]' | awk '{print $1}'`; do git branch -D $branch; done
  ```

<a name="writing-good-commit-messages"></a>
### 1.3 Writing good commit messages

Having a good guideline for creating commits and sticking to it makes working with Git and collaborating with others a lot easier. Here are some rules of thumb ([source](https://chris.beams.io/posts/git-commit/#seven-rules)):

 * Separate the subject from the body with a newline between the two.

    _Why:_
    > Git is smart enough to distinguish the first line of your commit message as your summary. In fact, if you try git shortlog, instead of git log, you will see a long list of commit messages, consisting of the id of the commit, and the summary only.

 * Limit the subject line to 50 characters and Wrap the body at 72 characters.

    _why_
    > Commits should be as fine-grained and focused as possible, it is not the place to be verbose. [read more...](https://medium.com/@preslavrachev/what-s-with-the-50-72-rule-8a906f61f09c)

 * Capitalize the subject line.
 * Do not end the subject line with a period.
 * Use [imperative mood](https://en.wikipedia.org/wiki/Imperative_mood) in the subject line.

    _Why:_
    > Rather than writing messages that say what a committer has done. It's better to consider these messages as the instructions for what is going to be done after the commit is applied on the repository. [read more...](https://news.ycombinator.com/item?id=2079612)


 * Use the body to explain **what** and **why** as opposed to **how**.

 <a name="documentation"></a>
## 2. Documentation

![Documentation](images/documentation.png)

* Use this [template](./README.sample.md) for `README.md`, Feel free to add uncovered sections.
* For projects with more than one repository, provide links to them in their respective `README.md` files.
* Keep `README.md` updated as a project evolves.
* Comment your code. Try to make it as clear as possible what you are intending with each major section.
* If there is an open discussion on github or stackoverflow about the code or approach you're using, include the link in your comment. 
* Don't use comments as an excuse for a bad code. Keep your code clean.
* Don't use clean code as an excuse to not comment at all.
* Keep comments relevant as your code evolves.

<a name="environments"></a>
## 3. Environments

![Environments](images/laptop.png)

* Prefer a `review`, `canary` and `production` environment model than a `development`, `test` and `production` environment. Use spaces on akkeris for this.

    _Why:_
    > This model is more or less the same as a dev, qa and prod model but differs in one aspect, the `canary` environment is production, and includes only clients who are either (you, or your own company to eat your own dog food), and/or close partners and/or not-for-profit.  The goal is to ensure the QA environment is treated with as much respect as possible, and therefore putting live clients within it forces people to treat it as such.  In addition, in this model any other team always integrate into each others `canary` environment rather than their `review`.  The `review` environment usually contains mocks of services for other teams and is isolated to each team.


* Define separate `development`, `test` and `production` environments, if needed.  Use spaces on akkeris for this.

    _Why:_
    > Different data, tokens, APIs, ports etc... might be needed in different environments. You may want an isolated `development` mode that calls fake API which returns predictable data, making both automated and manual testing much easier. Or you may want to enable Google Analytics only on `production` and so on.


* Load your deployment specific configurations from environment variables and never add them to the codebase as constants. 

    _Why:_
    > You have tokens, passwords and other valuable information in there. Your config should be correctly separated from the app internals as if the codebase could be made public at any moment. This helps protect our security, and enforces a seperation of code from config, make it easier to deploy the same code to different environments more reliably. (Hint: java/scala can use  `System.env("VARIABLE_NAME")` to pull environment variables, node can use `process.env["VARIABLE_NAME"]` every lagnauge has a way to pull these values.)

    _How:_
    >
    Create a `.env` file with KEY=VALUE pairs seperated by a new line, use `source .env` to slurp up the environment.  To resync your environment with an app in akkeris use `aka config -a [appname] -s > .env ; source .env`
    [read more](https://medium.com/@rafaelvidaurre/managing-environment-variables-in-node-js-2cb45a55195f)

* It’s recommended to validate environment variables before your app starts.  And provide a description of why its needed and where or how it could be found.
    
    _Why:_
    > It really will save others from hours of troubleshooting how to start your application, it takes 10 seconds for you to do, but saves someone hours.

<a name="consistent-dev-environments"></a>
### 3.1 Consistent dev environments:

* Use Docker image if you can.

    _Why:_
    > It can give you a consistent environment across the entire workflow. Without much need to fiddle with dependencies or configs. [read more...](https://hackernoon.com/how-to-dockerize-a-node-js-application-4fbab45a0c19)

* Use local modules instead of using globally installed modules. Depending on the language this requires sometime explictly avoiding global caches.

    _Why:_
    > Lets you share your tooling with your colleague instead of expecting them to have it globally on their systems.



<a name="dependencies"></a>
## 4. Dependencies

![Github](images/modules.png)


* Explicitly state your dependency and it's version somewhere.

    _Why:_
    > Because you want the code to behave as expected and identical in any development machine [read more...](https://medium.com/@kentcdodds/why-semver-ranges-are-literally-the-worst-817cdcb09277)
   
* Keep track of your current dependencies: e.g. on node use, `npm ls --depth=0`. [read more...](https://docs.npmjs.com/cli/ls)

    _Why:_
    > You should always know or have a way of showing what dependencies you have.

* See if any of your packages have become unused or irrelevant. e.g., on node use, `depcheck`. [read more...](https://www.npmjs.com/package/depcheck)
    
    _Why:_
    > You may include an unused library in your code and increase build times. Find unused dependencies and get rid of them.

* Before using a dependency, check its download statistics to see if it is heavily used by the community. e.g., on node use, `npm-stat`. [read more...](https://npm-stat.com/)
    
    _Why:_
    > More usage mostly means more contributors, which usually means better maintenance, and all of these result in quickly discovered bugs and quickly developed fixes.

* Before using a dependency, check to see if it has a mature version, a consistent release frequency, large number of maintainers or that any filed issues do not make it unusable for your needs. (It's Github's issues page is a great way of discovering this)

    _Why:_
    > Having loads of contributors won't be as effective if maintainers don't merge fixes and patches quickly enough. In addition if the release cycle or issues are beginning to slow (or pile up), its an indicator the dependency may no longer being actively maintained and should be avoided.

* If a less known dependency is needed, discuss it with your team before using it.

    _Why:_
    > Someone may know of a different dependency or approach that will work for you.  Or if you do want to take the risk, others can help review its impact with you.
    
* Always make sure your app works with the latest version of its dependencies without breaking.

    _Why:_
    > Dependency updates sometimes contain breaking changes. Always check their release notes when updates show up. Update your dependencies one by one, that makes troubleshooting easier if anything goes wrong. Use a cool tool such as [npm-check-updates](https://github.com/tjunnone/npm-check-updates).

* Check to see if the package has known security vulnerabilities with, e.g., [Snyk](https://snyk.io/test?utm_source=risingstack_blog).


<a name="testing"></a>
## 5. Testing
![Testing](images/testing.png)

> Any code without tests is legacy code.

* Have a way of putting your application into test (or debug) mode.

    _Why:_
    > While this may not be explicitly necessary, one example is that your API may have rate limits in its normal mode and blocks your test calls after a certain amount of requests. You may also want to have more interesting information outputted for tests running or in a specific environment that you may not want to see (or may not be compliant to see) when in production.

* For unit tests, place your test files next to the tested modules using `*.test.js` or `*.spec.js` naming convention.

    _Why:_
    > You don't want to dig through a folder structure to find a unit test. This makes refactoring much easier if a engineer can immediately find your unit tests and update them. [read more...](https://hackernoon.com/structure-your-javascript-code-for-testability-9bc93d9c72dc)
    

* Put acceptance, integration or other tests in a specific test folder.

    _Why:_
    > Some test files don't particularly relate to any specific implementation file. You have to put it in a folder that is most likely to be found by other developers: `test` folder. This name: `test`  is also standard now and gets picked up by most testing frameworks. However it can be named anything.

* Write testable code, avoid side effects, extract side effects, write pure functions

    _Why:_
    > You want to test a business logic as separate units. You have to "minimize the impact of randomness and nondeterministic processes on the reliability of your code". [read more...](https://medium.com/javascript-scene/tdd-the-rite-way-53c9b46f45e3)
    
    > A pure function is a function that always returns the same output for the same input. Conversely, an impure function is one that may have side effects or depends on conditions from the outside to produce a value. That makes it less predictable. [read more...](https://hackernoon.com/structure-your-javascript-code-for-testability-9bc93d9c72dc)

* Use a static type checker 

    _Why:_
    > Sometimes you may need a Static type checker. It brings a certain level of reliability to your code. [read more...](https://medium.freecodecamp.org/why-use-static-types-in-javascript-part-1-8382da1e0adb)


* Run tests locally before making any pull requests to `master` (or whatever your main branch is called).

    _Why:_
    > You don't want to be the one who caused production-ready branch build to fail. Run your tests after your `rebase` and before pushing your feature-branch to a remote repository.

* Document your tests including instructions on how to setup in the relevant section of your `README.md` file.

    _Why:_
    > It's a handy note you leave behind for other developers or DevOps experts or QA or anyone who gets lucky enough to work on your code.
  
* Document where someone can find integration tests (if they happen to exist in a seperate repo)

    _Why:_
    > It's great to know if there are other tests that can be ran and where they may exist so an engineer can update those as well.

* All tests in the main test suite should be runnable and pass always.

    _Why:_
    > One bad test not fixed make it so everyone ignroes *ALL* the tests. No one hates it more than to find tests that have been failing for 6 months and subsequently everyone has just started to ignore tests completely.  If you don't have time to fix it, move it to a folder called failing and file a JIRA or Github issue about fixing it.  
    
* All tests in the main test suite should be reliable.

    _Why:_
    > Tests that fail sometimes and pass sometimes reduces others confidence in ALL the tests that are being ran. If a test is "flaky", don't hesitate to remove it from the main test suite, but put it in a sub-folder with documentation on how it can be ran, and that its sometimes flaky.

* Add code coverage to your project

    _Why:_
    > Code coverage gives you a great idea of which features already have enough tests or where features may be more 'unstable' allowing engineers to be more deliberate about making changes in certain areas.

* Encourage different levels of integration/acceptance testing

    _Why:_
    > Some tests can do a great job at covering a very small corner case, but be incredibly flaky or difficult to setup. Having different classifications of tests (l1, l2, l3) or by feature allow people to pick and chose to run some tests while not others.




<a name="selfservice"></a>
## 6. Self-service and Workflow

![Github](images/service.png)

> The only system that's scalable is one that's self-serviced.

* If your API requires setup for credentials or configuration, create an administrative website or CLI aka plugin.

    _Why:_
    > This has a few benefits:
    > 1. In order to use your service some people in the organization may not know who to talk to, and if you're the main point of contact, and if you leave, no one knows.
    > 2. If you want to encourage adoption of a service do everything you can to not be a barrier to it.
    > 3. It decouples communication and lets others work more independently.
    > 4. You don't find yourself bogged down taking requests or unnecessarily spending time setting things up.

* If you've done something manually more than once, notice it; on the third time automate it.  Create a plugin on the CLI and publish it to our akkeris plugin registry.

    _Why:_
    > There's a lot of common engineering tasks that can be shortened with a quick script. Creating that script and publishing it to our plugin registry is an easy an effective way of allowing other engineers to benefit from your work. The best part is its discoverable, you don't necessarily need to tell anyone. 

* Provide documentation for your downstream users.  Even if they're the team next door.

    _Why:_
    > It's easy to think that you can just explain your system, API or whatever if someone is interested, but with the lag between engineering and adoption its quite likely when someone wants to use what you've done you'll have either forgotten that explanation or will no longer be involved with that system, ensure you provide enough documentation in your repo's README.md so that anyone can use your system, API or client.


<a name="structure-and-naming"></a>
## 7. Structure and Naming
![Structure and Naming](images/folder-tree.png)

* **Follow default conventions of your language or framework first, all other rules below are secondary**.


    _Why:_
    > Some languages and frameworks use conventions so that engineers can expect to find specific types of code in specific places, changing these defaults often leads to headaches for others picking up your project that are used to a standard expectation. 

* Organize your files around product features / pages / components, not roles.


    **Bad**

    ```
    .
    ├── controllers
    |   ├── product.js
    |   └── user.js
    ├── models
    |   ├── product.js
    |   └── user.js
    ```

    **Good**

    ```
    .
    ├── product
    |   ├── index.js
    |   ├── product.js
    |   └── product.test.js
    ├── user
    |   ├── index.js
    |   ├── user.js
    |   └── user.test.js
    ```

    _Why:_
    > Instead of a long list of files, you will create small modules that encapsulate one responsibility including its test and so on. It gets much easier to navigate through and things can be found at a glance.

* Put your additional test files to a separate test folder to avoid confusion.

    _Why:_
    > It is a time saver for other developers.

* Use a ./config folder to define internal app values derived from environment variables; **DON'T make different config files for different environments**

    _Why:_
    >When you break down a config file for different purposes (database, API and so on); putting them in a folder with a very recognizable name such as `config` makes sense. Just remember not to make different config files for different environments. It doesn't scale cleanly, as more deploys of the app are created, new environment names are necessary. [read more...](https://medium.com/@fedorHK/no-config-b3f1171eecd5)
    

* Put your scripts in a `./scripts` folder. This includes setup, build or other `bash` scripts.

    _Why:_
    > It's very likely you may end up with more than one script, builds, database feeders, database synchronization and so on.
    

* Place your build output in a `./build` folder. Add `build/` to `.gitignore`.

    _Why:_
    >Name it what you like, `dist` is also cool. But make sure that keep it consistent with your team. What gets in there is most likely generated  (bundled, compiled, transpiled) or moved there. What you can generate, your teammates should be able to generate too, so there is no point committing them into your remote repository. Unless you specifically want to. 

<a name="code-style"></a>
## 8. Code style

![Code style](images/code-style.png)

<a name="code-style-check"></a>
### 8.1 Some code style suggestions (not demands!)

* Do not use proposed features of a language, or even approved if they have not yet been implemented (e.g., you're using a transpiler). For old project stay consistent with existing syntax unless you intend to modernise the project.

    _Why:_
    > New features are great, but its not uncommon for a language feature to be amended or changed during its implementation phase due to situations that were not fully considered during the proposal or approval process. Once a feature has been fully implemented by a major vendor its safe to say its well vetted and generally available. 

* If code style is an issue, include a git hook to check the style.

    _Why:_
    > A git hook allows you to run any arbitrary command on each commit, the command must return successfully for the commit to continue, you can add these hooks to prevent anyone from pushing unless, say a linter passes. [read more..](https://dev.ghost.org/prevent-master-push/)

* Use linters and place the linters rc file at the root to enforce code style.

    _Why:_
    > Someone adopting a project can simply look at the linter to know what code styles should be used (and can automatically run a linter command on it)

* Depending on the size of the task use  `//TODO:` comments to remind yourself of something to finish later, reference a JIRA ticket if its a larger task.

    _Why:_
    > So then you can remind yourself and others about a small task (like refactoring a function or updating a comment). For larger tasks use `//TODO(#3456)` which is enforced by a lint rule and the number is an open ticket.


* Always comment and keep them relevant as code changes. Remove commented blocks of code.
    
    _Why:_
    > Your code should be as readable as possible, you should get rid of anything distracting. If you refactored a function, don't just comment out the old one, remove it.

* Avoid irrelevant or funny comments, logs or naming.

    _Why:_
    > While your build process may(should) get rid of them, sometimes your source code may get handed over to another company/client and they may not share the same banter.

* Organize your functions in a file according to the step-down rule. Higher level functions should be on top and lower levels below.

    _Why:_
    > It makes it more natural to read the source code.

* Avoid demo user details taken from your team or using unrealistic names, instead use data generators for fake names, avatars and more [read more](https://randomuser.me/)

    _Why:_
    > Using real data for some products demo information can create some compliance headaches and be viewed as unprofessional, in addition fake names (should you need to do client demo's) should be realistic. Using a random name and avatar generator can help with this.



<a name="enforcing-code-style-standards"></a>
### 8.2 Enforcing code style standards

* Consider using Git hooks.

    _Why:_
    > Git hooks greatly increase a developer's productivity. Make changes, commit and push to staging or production environments without the fear of breaking builds. [read more...](http://githooks.com/)

* Use code prettier as a precommit hook if the code style issue is somewhat non-contraversal.

    _Why:_
    > For things commonly forgotten about (spaces after the last line), use a prettier to remove these and place it as a git precommit hook, it will automatically remove this and keep your code clean. 


<a name="logging"></a>
## 9. Logging

![Logging](images/logging.png)

* Avoid client-side console logs in javascript for production

    _Why:_
    > The console logs may be noticed by clients or customers, keep it classy and professional.

* Produce readable production logging.

    _Why:_
    > Logging in production helps you diagnose issues, use this to your advantage, colorize your output and be consistent about conventions. Know that your logging is searchable so think about what keywords or classifications may be helpful to add to a log line to make it findable.

* **NEVER** log out customer or client information (PII or otherwise).

    _Why:_
    > This can lead to very serious compliance and security issues. In addition logging may not be easily removed or erradicated. 

* **NEVER** log out security credentials (auth tokens, passwords).

    _Why:_
    > This can lead to very serious compliance and security issues. In addition logging may not be easily removed or erradicated. 

* **NEVER** turn on debug logging in production for systems. 

    _Why:_
    > This can leak serious environment credentials and customer information and should never be done.


<a name="api"></a>
## 10. API
<a name="api-design"></a>

![API](images/api.png)

### 10.1 API design

> Because we try to enforce development of sanely constructed RESTful interfaces, which team members and clients can consume simply and consistently.   Lack of consistency and simplicity can massively increase integration and maintenance costs. Which is why `API design` is included in this document.

* Use x-request-id convention to track nested API calls

    _Why:_
    > X-Request-Id is an http header that is displayed in logs for each http request coming in (sometimes it's shown as request_id).  
    >
    > `Jan 29 11:22:13 some-app router:  host=www.example.com method=GET path=/apps/eventsub-jam-prd/formation x_request_id=b36d8c3fde06d880ecec699959065334 status=200 service=17 connect=9 total=27 bytes=1206`
    >
    > It allows tracking requests across multiple API calls. If no x-request-id is provided our router will automatically generate one.  Perferably the front-end or client systems should generate one that has significance (the user id, client id or session id or combination of them). Ensure if you're an API receiving a request (and making one) that you pass this x-request-id along to any downstream API calls you make as an http header. [read more](https://blog.heroku.com/http_request_id_s_improve_visibility_across_the_application_stack) 

* We mostly follow resource-oriented design. It has three main factors: resources, collection, and URLs.

    * A resource has data, gets nested, and there are methods that operate against it.
    * A group of resources is called a collection.
    * URL identifies the online location of resource or collection.
    
    _Why:_
    > This is a very well-known design to developers (your main API consumers). Apart from readability and ease of use, it allows us to write generic libraries and connectors without even knowing what the API is about.

* Use kebab-case for seperating multiple words in URLs.

    _Why:_
    > URL's can be case insensitive (e.g., helloWorld and helloworld are the same thing) on broken proxy services, or due to browser bugs, this makes using camelCase somewhat risky, using natural case (e.g, spaces "hello world") is not recommended as issues arise with clients not URI encoding correctly. Finally underscores are not supported on older http 1.0 clients.

* Use plural kebab-case for resource names in URLs.

    _Why:_
    > URL's can be case insensitive (e.g., helloWorld and helloworld are the same thing) on broken proxy services, or due to browser bugs, this makes using camelCase somewhat risky, using natural case (e.g, spaces "hello world") is not recommended as issues arise with clients not URI encoding correctly. Finally underscores are not supported on older http 1.0 clients.


* Use a plural nouns to indicate something is a REST collection: `/users`.

    _Why:_
    > As a convention the plurality and that its a noun (`users`) indicates a REST (non-RPC api) that's a resource and a collection.  RPC end points as you might imagine should be a VERB like `create` and plurality can vary. [read more...](https://apigee.com/about/blog/technology/restful-api-design-plural-nouns-and-concrete-names)

* Use non-plural verb (or verb first + noun) to indicate an API is a RPC call and not a REST interface: `/activate` or `/activate-cellphone`.

    _Why:_
    > As a convention the verb and the lack of it being plural indicates its an RPC end point and makes it easier/quicker for developers to make decisions.
 
* For CRUD or REST, always use a singular concept that starts with a collection and ends to an identifier:

    ```
    /students/245743
    /airports/kjfk
    ```
* For CRUD or REST, avoid URLs like this: 
    ```
    GET /posts/:post_id/summary
    ```

    _Why:_
    > This is not pointing to a resource but to a property instead. You can pass the property as a parameter to trim your response.

* Keep verbs out of your REST resource URLs (but ok for RPC).

    _Why:_
    > Because REST API's should behave much like a file, creations are `POST /resources`, deletions are `DELETE /resources/:resource_id`, updates are `PATCH /resources/:resource_id` and `PUT /resources/:resource_id`.  The actual english verb maps to an http verb, so putting a verb in the url such as `DELETE /resources/deleteResource/:resource_id` is redundant.

* Use verbs for RPC or non-resource API calls.  
    
    _Why:_
    > In this case, your API doesn't return any resources. Instead, you execute an operation and return the result that may or may not have state associated. These end points if modifying data that persists or takes an action (such as sending an email or writing to a database) should use a POST, otherwise GET is fine (note, DELETE, PATCH/PUT are somewhat unnecessary, but generally indicate data modification as well). You usually don't develop many of these. [read more...](https://byrondover.github.io/post/restful-api-guidelines/#controller)

* Do not use RPC calls when REST (CRUD) calls can accomplish the same thing.

    _Why:_
    > Conventions make it easier and quicker to develop code, and it allows engineers to expect things immediately. Avoid endpoints like `/addNewUser` or `/updateUser` and `/deleteUser` and instead convert it to REST (CRUD) interface that takes advantage of HTTP verbs: `POST /users`, `PUT /users/:user_id` and `DELETE /users/:user_id`. 

* **NEVER** pass sensitive information (such as authentication tokens) in query string parameters

    _Why:_
    > ALL query parameters will appear in not just our http logs but many proxy systems between our clients and our end points, thus exposing that data to others.
    
* Explain the CRUD (REST) functionalities using HTTP methods:

    _How:_
    > `GET`: To retrieve a representation of a resource.
    
    > `POST`: To create new resources and sub-resources.
   
    > `PUT`: To update existing resources.
    
    > `PATCH`: To update existing resources. It only updates the fields that were supplied, leaving the others alone.
    
    > `DELETE`:	To delete existing resources.


* For nested resources, use the relation between them in the URL. For instance, using `id` to relate an employee to a company.

    _Why:_
    > This is a natural way to make resources explorable.

    _How:_

    > `GET      /schools/2/students	` , should get the list of all students from school 2.

    > `GET      /schools/2/students/31`	, should get the details of student 31, which belongs to school 2.

    > `DELETE   /schools/2/students/31`	, should delete student 31, which belongs to school 2.

    > `PUT      /schools/2/students/31`	, should update info of student 31, Use PUT on resource-URL only, not collection.

    > `POST     /schools` , should create a new school and return the details of the new school created. Use POST on collection-URLs.

* Use a simple ordinal number for a version with a `v` prefix (v1, v2). Move it all the way to the left in the URL so that it has the highest scope:
    ```
    http://api.domain.com/v1/schools/3/students	
    ```

    _Why:_
    > When your APIs are public for other third parties, upgrading the APIs with some breaking change would also lead to breaking the existing products or services using your APIs. Using versions in your URL can prevent that from happening. [read more...](https://apigee.com/about/blog/technology/restful-api-design-tips-versioning)



* Response messages must be self-descriptive. A good error message response might look something like this:
    ```json
    {
        "code": 1234,
        "message" : "Something bad happened",
        "description" : "More details"
    }
    ```
    or for validation errors:
    ```json
    {
        "code" : 2314,
        "message" : "Validation Failed",
        "errors" : [
            {
                "code" : 1233,
                "field" : "email",
                "message" : "Invalid email"
            },
            {
                "code" : 1234,
                "field" : "password",
                "message" : "No password provided"
            }
          ]
    }
    ```

    _Why:_
    > developers depend on well-designed errors at the critical times when they are troubleshooting and resolving issues after the applications they've built using your APIs are in the hands of their users.


    _Note: Keep security exception messages as generic as possible. For instance, Instead of saying ‘incorrect password’, you can reply back saying ‘invalid username or password’ so that we don’t unknowingly inform user that username was indeed correct and only the password was incorrect._

* Use only these 11 status codes to send with you response to describe whether **everything worked**,
The **client app did something wrong** or The **API did something wrong**.
    
    _Which ones:_
    > `200 OK` response represents success for `GET`, `PUT` or `POST` requests.

    > `201 Created` for when a new instance is created (and commited). Creating a new instance, using `POST` method returns `201` status code.

    > `202 Accepted` for when a new instance is created but will take sometime to propogate or commit. This should **ALWAYS** return a "Location" header response to indicate the URL to check on the status of the request.

    > `304 Not Modified` response is to minimize information transfer when the recipient already has cached representations.

    > `400 Bad Request` when you receive a malformed request (syntactically it was non-processable, data fields were missing or wrong, or you expected it to be JSON and you got XML).

    > `401 Unauthorized` for when the request lacks valid credentials and it should re-request with the required credentials.

    > `403 Forbidden` means the server understood the request but refuses to authorize it.

    > `404 Not Found` indicates that the requested resource was not found. 

    > `422 Unprocessible Entity` indicates that the request was valid,some business rule failed and it could not be completed.

    > `500 Internal Server Error` indicates that the request is valid, but the server could not fulfill it due to some unexpected condition.
    
    > `504 Upstream Error` indicates that the request is valid, but the server could not fulfill it due to a resource it relies on being unavailable (such as a database or server).  This indicates YOUR api is NOT the issue, something else your api depends on is (very useful when reviewing http logs for error tracing).

    _Why:_
    > Most API providers use a small subset HTTP status codes. For example, the Google GData API uses only 10 status codes, Heroku uses 12, and Digg, only 8. Of course, these responses contain a body with additional information.There are over 70 HTTP status codes. However, most developers don't have all 70 memorized. So if you choose status codes that are not very common you will force application developers away from building their apps and over to wikipedia to figure out what you're trying to tell them. [read more...](https://apigee.com/about/blog/technology/restful-api-design-what-about-errors)


* Provide total numbers of resources in your response.
* Accept `limit` and `offset` parameters.

* The amount of data the resource exposes should also be taken into account. The API consumer doesn't always need the full representation of a resource.Use a fields query parameter that takes a comma separated list of fields to include:
    ```
    GET /student?fields=id,name,age,class
    ```
* Pagination, filtering, and sorting don’t need to be supported from start for all resources. Document those resources that offer filtering and sorting. If supported, prefer `min_id`, `max_id` and `count` over `limit` and `offset`. 

    _Why:_
    > Using a min, max and count offers more flexibility to clients querying your API than a limit and offset. [read more](https://developer.twitter.com/en/docs/tweets/timelines/guides/working-with-timelines)

* Target an API response times of:

    > 1. DNS Lookup times should target 13ms
    > 2. TLS negotation times should target 30s with 3ms average with 1.2 TLS Session Resumption
    > 3. Time to First Byte (TTFB), 14.9ms
    > 4. Time to Last Byte (TTLB, for < 10kb payloads), 35ms
    > [read more](api-performance.md)


<a name="api-security"></a>
### 10.2 API security
These are some basic security best practices:

* **NEVER** expose your API over http

    _Why:_
    > This is suceptible to man in the middle attacks and allows proxying attacks. It's also out of compliance and our infosec team will cry. No http, not once.

* **NEVER** include tokens as query parameters

* Tokens must be transmitted using the Authorization header on every request: `Authorization: Bearer xxxxxx, Extra yyyyy`.

* Authorization code should be short-lived.

* Reject any non-TLS requests by not responding to any HTTP request to avoid any insecure data exchange. Respond to HTTP requests by `403 Forbidden`.

* Consider using Rate Limiting.

    _Why:_
    > To protect your APIs from bot threats that call your API thousands of times per hour. You should consider implementing rate limit early on.

* Setting HTTP headers appropriately can help to lock down and secure your web application. [read more...](https://github.com/helmetjs/helmet)

* Your API should convert the received data to their canonical form or reject them. Return 400 Bad Request with details about any errors from bad or missing data.

* All the data exchanged with the ReST API must be validated by the API.

* Serialize your JSON.

    _Why:_
    > A key concern with JSON encoders is preventing arbitrary JavaScript remote code execution within the browser... or, if you're using node.js, on the server. It's vital that you use a proper JSON serializer to encode user-supplied data properly to prevent the execution of user-supplied input on the browser.

* Validate the content-type and mostly use `application/*json` (Content-Type header).
    
    _Why:_
    > For instance, accepting the `application/x-www-form-urlencoded` mime type allows the attacker to create a form and trigger a simple POST request. The server should never assume the Content-Type. A lack of Content-Type header or an unexpected Content-Type header should result in the server rejecting the content with a `4XX` response.

* Check the API Security Checklist Project. [read more...](https://github.com/shieldfy/API-Security-Checklist)


<a name="api-documentation"></a>
### 10.3 API documentation
* Fill the `API Reference` section in for API.
* Describe API authentication methods with a code sample.
* Explaining The URL Structure (path only, no root URL) including The request type (Method).

For each endpoint explain:
* URL Params If URL Params exist, specify them in accordance with name mentioned in URL section:

    ```
    Required: id=[integer]
    Optional: photo_id=[alphanumeric]
    ```

* If the request type is POST, provide working examples. URL Params rules apply here too. Separate the section into Optional and Required.

* Success Response, What should be the status code and is there any return data? This is useful when people need to know what their callbacks should expect:

    ```
    Code: 200
    Content: { id : 12 }
    ```

* Error Response, Most endpoints have many ways to fail. From unauthorized access to wrongful parameters etc. All of those should be listed here. It might seem repetitive, but it helps prevent assumptions from being made. For example
    ```json
    {
        "code": 403,
        "message" : "Authentication failed",
        "description" : "Invalid username or password"
    }   
    ```


* Use API design tools, There are lots of open source tools for good documentation such as [API Blueprint](https://apiblueprint.org/) and [Swagger](https://swagger.io/).

<a name="resources"></a>
## 11. Resources
![Resources](images/licensing.png)

* Never put personally identifiable data of our customers on non-on-prem data stores. 

    _Why:_
    > We (for the time) have agreed with our customers and clients and from SOCS to never store their email address, name, phone number or address on anything but hardware we own. 

* Resources should use a URI format

    _Why:_
    > A standard monikor for describing a resource is a URI, whether its website `https://host/path/name?additional=params` or a database `postgres://user:pass@host:port/dbname` or a redis `redis://hostname:port/` it allows a standard way of describing a connected resource and fits into one simple string.  Many libraries for languages now accept URI's instead of having to set a host, port, username and password seperately. Also, environment variables should store the resource as a URI in one variable name!


* Resources with shared credentials should be added to vault

    _Why:_
    > This provides a central place where the password can be rotated and updated. In addition the credentials can be injected as an addon for apps (or automatically inserted into the environment for legacy apps!)


<a name="performance"></a>
## 12. Performance
![Performance](images/performance.png)

> Performance optimizing can often times make things worse, don't try and optimize your code unless you have an objective reason to do so.  But here's some common performance mistakes.

* Use connection pooling and keep-alives with your resources. 

    _Why:_
    > Connecting to resources can often have a huge overhead. Connecting to a database can have a 100ms overhead, connection pooling leaves the connection idle and does not close it after a query but waits for a new query needing to be run and runs it on the already connected link.  This can considerably make your queries faster since you no longer need to incur the overhead of 100ms

* Use cache headers appropriately with your API's (such as `Vary`)

    _Why:_
    > This informs HTTP callers on your API to cache results for a certain length of time and only invalid their cache when specific conditions change.  This can be an amazing help for a lot of API's that may not have data that changes often (as it completely prevents the request from ever being sent.)

* Prefer streaming rather than buffering

    _Why:_
    > Often times when reading a file upload and storing it to an S3, or if you're pulling in database records you'll have the option to either deal with data as it's coming in as chunks (streaming) or waiting for the entire data set to be ready (buffering).  Streaming deals with only a near (or certainly more predicable) constant amount of data, where as a buffer waits for all the data that is being sent.  Handling data with streams helps prevent out of memory errors. In addition streaming can often times be more effective as it allows you to immediately process data as its being received making the perceived performance faster.  On databases this can be controlled by settings such as fetch size and batch size.  Within I/O look for options to pipe source and destination I/Os. [read more](http://book.mixu.net/node/ch9.html#9-3-streams)


* Some performance API goals:

    > 1. DNS Lookup times should target 13ms
    > 2. TLS negotation times should target 30s with 3ms average with 1.2 TLS Session Resumption
    > 3. Time to First Byte (TTFB), 14.9ms
    > 4. Time to Last Byte (TTLB, for < 10kb payloads), 35ms
    > Why these numbers? [read more](api-performance.md)

* Careful listening to high-throughput events on the document object model (front-end), such as mouse move or scroll events.

    _Why:_
    > Listening to these events can cause thousands of callbacks to your code, in addition is frequently teh cause of unresponsive user interfaces due to high amounts of paint, layout and composite calls.


<a name="licensing"></a>
## 13. Licensing

Make sure you use resources that you have the rights to use. If you use libraries, remember to look for MIT, Apache or BSD but if you modify them, then take a look at the license details. Copyrighted images and videos may cause legal problems.

## 14. Credits

Much of this was based off of work done by the following:

Sources:
[Hive Javascript Guidelines](https://github.com/wearehive/project-guidelines)
[RisingStack Engineering](https://blog.risingstack.com/),
[Mozilla Developer Network](https://developer.mozilla.org/),
[Airbnb/javascript](https://github.com/airbnb/javascript),
[Atlassian Git tutorials](https://www.atlassian.com/git/tutorials),
[Apigee](https://apigee.com/about/blog),
[Wishtack](https://blog.wishtack.com)

Icons by [icons8](https://icons8.com/)


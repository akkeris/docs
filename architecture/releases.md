# Releases

Whenever you deploy code, or change a config var, or remove (or add) an add-on resources you implicitly create a new release and automatically will cause your application to restart.  You can see a history of releases, and roll back a release to revert the prior changes (if needed) through the CLI (`aka releases:rollback`), UI or Platform Apps API.

## Release Creation

Releases are named `vNNN` where the `NNN` indicates the release id.  The release's are sequential and unique to the application.  One way to create a release is by manually providing a set of sources to build.

```bash
aka releases:create https://example.com/source_code.zip -a myapp-myspace
Deploying https://example.com/source_code.zip to myapp-myspace ... ✓
```

You can also trigger a new release by commiting into a branch on a source control repository Akkeris is watching.  

```bash
git commit -a -m 'My commit message' ; git push
remote: Counting objects: 75, done.
remote: Compressing objects: 100% (53/53), done.
remote: Total 62 (delta 27), reused 44 (delta 9)
Unpacking objects: 100% (62/62), done.
```

```bash
aka releases -a myapp-myspace
• v1	1 minute ago	Auto-Deploy 6d58b1ce - User (username) - My commit message - ef5c71a
```

## Listing Release History

To see the history of releases for an app:

```bash
aka releases -a myapp-myspace
• v1	16 days ago	Auto-Deploy 6d58b1ce - GithubUser2 (Github User 1) - Another commit - ef5c71a
• v2	14 days ago	Auto-Deploy e08c02cb - GithubUser3 (Github User 2) - Some merge commit  - 3ad31be
• v3	10 days ago	Auto-Deploy cbc06f1b - GithubUser1 (GithubUser 3) - yet another - ece6039
• v4	9 days ago	Auto-Deploy 52aeae74 - c4357b9
```

## Rollback

Use the rollback command to revert to the previous release:

```bash
aka rollback -a myapp-myspace
Rolling back to v3 on myapp-myspace
```

You may choose to specify another release to target:

```bash
aka rollback v1 -a myapp-myspace
Rolling back to v1 on myapp-myspace
```

Rolling back will create a new release which is a copy of the state of the compiled slug and config vars of the release specified in the command. The state of your source code repository, database, and external state held in add-ons (for example, the contents of memcache) will not be affected and is your responsibility to reconcile with the rollback.

Running on a rolled-back release is meant as a *temporary fix* to a bad deployment. If you are on a rolled-back release, fix and commit the problem locally, and re-push to akkeris.

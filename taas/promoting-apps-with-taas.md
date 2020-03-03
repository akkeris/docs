# Taas App Promotion

## Why?

Taas can automatically promote apps in a pipeline when a test succeeds. Multiple Taas tests can be chained together and used to automate the entire deployment process! This means a new code release can be deployed and tested in each pipeline stage with a single click.

## How?
If each app in the pipeline is targeted by a Taas test, Taas can automatically move the app through the pipeline as each test passes.

Consider the following Akkeris pipeline:

| Review     | Development | Staging | Production |
|------------|-------------|---------|------------|
| app-review | app-dev     | app-stg | app-prd    |

We can create Taas tests for each app:

| App        | Taas Test       | Promotion Setting                                        |
|------------|-----------------|----------------------------------------------------------|
| app-review | app-review-taas | Automatic: From review:app-review To development:app-dev |
| app-dev    | app-dev-taas    | Automatic: From development:app-dev To staging:app-stg   |
| app-stg    | app-stg-taas    | Automatic: From staging:app-stg To production:app-prd    |
| app-prd    | app-prd-taas    | Manual                                                   |

The workflow would then look like this:
1. The `app-review-taas` test will be kicked off when a new release on `app-review` is created via Github auto build. If the test is successful, Taas will promote `app-review` to `app-dev`.
2. The `app-dev-taas` test will be kicked off when a new release on `app-dev` is created via promotion from Step 1. If the test is successful, Taas will promote `app-dev` to `app-stg`.
3. The `app-stg-taas` test will be kicked off when a new release on `app-stg` is created via promotion from Step 2. If the test is successful, Taas will promote `app-stg` to `app-prd`.
4. The `app-prd-taas` test will be kicked off when a new release on `app-review` is created via promotion from Step 3. The purpose of this test would not be for app promotion, but for smoke testing.

Each Taas test could use the same image but with different environment variables. 

If at any point in the pipeline a Taas test fails, the promotion will not occur and the new code will not make it to production.
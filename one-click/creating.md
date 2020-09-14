# One Click Apps

One click applications are definitions of applications that can be created quickly an easily.  They define all of the components necessary to get an application up and running.  When you create a 'one-click' app it gives you a URL that you can give to others or place in a web site that when clicked will create the application (or ask for any additional information as necessary).

## Creating One Click Urls

If there's an existing app that can be used for the blue print and does not require and changes to the blue print you can create a one click url by running:

```shell
aka apps:blueprint -a [appname-space] -u 
```

## Customizing One Click Urls

You can create one click apps by first creating a blueprint.  Generally the best way to go about this is by manually creating the application on Alamo, once you're finished run:

```shell
aka apps:blueprint -a [appname-space] > blueprint.json
```
You can then modify the blueprint.json file and change any of the parameters as needed.  A reference for the app setups blue print can be found in the [App Setups](/architecture/apps-api/App-Setups.md) section of the Platform Apps API.

Once your blueprint is to your liking you can optionally add the "name", "description" and "icon" field off the the root of the JSON object (all as strings) to provide more meta information that a user would see when setting up the app.  

To create your blue print one-click url run:

```shell
aka apps:one-click -f blueprint.json
```

You should then get your blue print URL that you can use to re-create the same app as needed (even if the existing app is deleted).  Note: none of the data from the original app is copied, in addition if the app you used had secure secrets they will would have been removed from the blueprint and when creating the new app from the blueprint the user may be asked to provide these.


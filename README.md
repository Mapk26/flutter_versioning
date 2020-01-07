# Versioning

A simple Flutter package that check current app version against a Firebase database.
It is useful to inform users about a new upgrade by an alert or
block the navigation showing a default screen if the update is mandatory.
As well, you can choose to temporary lock your app with a "Mainteinance mode" screen.

## Getting Started

This package requires a Firebase realtime database (not Cloud Firestore!),
you don't need the Firebase SDK in your Flutter project.

The database must have this structure:

```
- appname
    - android
        buildNumber: 1
        lastBreakingChange: 0
        maintenanceMode: false
        platform: Android
    - ios
        buildNumber: 1
        lastBreakingChange: 0
        maintenanceMode: false
        platform: iOS
```

This way you can handle multiple apps inside the same Firebase project.

### How to use those fields?

appname: simply give it the name of your project or whatever you want.
buildNumber: can be different for Android and iOS. If this builNumber is greater than the current
app version, a popup alert will suggest the user to upgrade. Clicking on "Upgrade" will jump directly to the store.
lastBreakingChange: if you want to force users to upgrade to a new version, put this value equal to
the buildNumber.
For example: you have release app 1.4.0+10, then the buildNumber is 10. Let's suppose you release a new hotfix and you want to be sure that
all users upgrade to it. New version will be 1.4.1+11, so buildNumber and lastBreakingChange will be both 11.
maintenanceMode: if 'true' a maintenance mode screen will appear preventing the user to use the app.
platform: it's just redundant but I liked to see it on the returned JSON.


## The Widget

```dart
import 'package:versioning/versioning_package.dart';

@override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Versioning(
        projectId: 'your-firebase-project',
        projectName: 'your-app-name',
        options: new VersioningOptions(
          backgroundColor: Colors.blue,
          iconUpdate: Icon( Icons.update, size: 60, color: Colors.white,),
          ...
        ),
        child: MyHomePage(title: 'Flutter Demo'),
      ),
    );
  }
```

That's it!
Now Versioning will call the Firebase database you've created and check the current app build number
against the 'buildNumber' you specified inside the DB.
Versioning will get the current platform so you can specify different build numbers for Android and iOS.

It fires at the app's start only and triggers again when the lifecycle of the app changes.

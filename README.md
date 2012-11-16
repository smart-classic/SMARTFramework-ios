SMART iOS Framework
===================

These are the developer instructions on how to use [SMARTFramework], an iOS framework to interface with a **[SMART container][smart]**.

### Requirements ###

- #### Objective-C ####
The SMART Framework is an Objective-C framework using **ARC** ([Automatic Reference Counting][arc]), requiring **iOS 5.0 or greater**. It also uses some of the new Objective-C language features which means you must use **Xcode 4.4** or later. You can use it as a static library (or directly import the code files into your App project) as documented below.  
The framework utilizes a fork of [MPOAuth], an OAuth framework by Karl Adam (matrixPointer), and an Objective-C wrapper around [Redland], an RDF library, originally created by Rene Puls.

- #### SMART Container ####
You need a [SMART container] running version 0.6 or above

[smartframework]: https://github.com/chb/SMARTFramework-ios
[smart]: http://www.smartplatforms.org/
[arc]: http://clang.llvm.org/docs/AutomaticReferenceCounting.html
[mpoauth]: https://github.com/chb/MPOAuth
[redland]: https://github.com/p2/Redland-ObjC
[smart container]: https://github.com/chb/smart_server


Technical Documentation
-----------------------

The code is documented using [appledoc] which you can build yourself as follows or install via [Homebrew]. After installing you can run the `SMART iOS Documentation` target right from within Xcode.

Building and installing appledoc yourself:

    $ cd SMARTFramework-ios/
    $ git clone git://github.com/tomaz/appledoc.git
    $ cd appledoc
    $ ./install-appledoc.sh -b /usr/local/bin -t ~/Library/Application\ Support/appledoc

Note that this assumes that you have write permissions for `/usr/local`, if not you may need to issue this command as root with `sudo`.

As of this writing I'm still waiting for appledoc 3.0 to be released. It will add support for the `///<` property documentation style used in core parts of the framework, version 2.0 will therefore not document some of the properties I'm afraid.

After installing and running the documentation target the documentation is available from within Xcode, just `ALT`-click any keyword like you would do with standard Cocoa keywords.

[appledoc]: http://gentlebytes.com/appledoc/
[homebrew]: http://mxcl.github.com/homebrew/


Server Side Setup
-----------------

Here is an example app manifest which would be the one you want to use with the Medications Sample App:

```javascript
{
  "name" : "Medications Sample",
  "description" : "A sample iOS app showing a list of medications",
  "author" : "Pascal Pfiffner, Harvard Medical School",
  "id" : "medsample@apps.smartplatforms.org",
  "version" : "1.0",
  "smart_version": "0.6",
  
  "mode" : "ui",
  "scope" : "record",
  
  "index" :  "smart-app:///did_select_record",
  "oauth_callback": "smart-app:///did_receive_verifier",
  "icon" :  "http://apiverifier.smartplatforms.org/static/images/icon.png"
}
```

Getting the Framework
---------------------

I'll be assuming that you want to add the framework to your own project. The best way to get the framework is to check out the project via [git], if your own project is also git-controlled, add it as a submodule using `git submodule add ...` instead of git clone. Open Terminal, navigate to the desired directory, and execute:

    $ git clone git://github.com/chb/SMARTFramework-ios.git
    $ cd SMARTFramework-ios
    $ git submodule init
    $ git submodule update

You now have the latest source code of the framework as well as the subprojects we use and the Medications Sample App. From now on you can just update to the latest source version with:

    $ cd SMARTFramework-ios
    $ git pull
    $ git submodule update --init --recursive


[git]: http://git-scm.com/


Running the Medication Sample App
---------------------------------

If you have checked out the source from GitHub, open the SMARTFramework workspace (at `SMARTFramework-ios/MARTFramework.xcworkspace`) in Xcode. Expand the SMARTFramework group and right-click the file `Config-default.h`, select **show in Finder**. Duplicate this file and rename it to `Config.h`, the settings are correct for the app to run against our developer sandbox, so no need to adjust. Then make sure you have the **SMART Medications Sample** target selected and hit Run.

> **Note:** The first time the framework is built it will download and compile the [Redland] C libraries for you. This may take some time and Xcode will not show any progress, just be patient.


Framework Setup
---------------

Now that you have the source it's time to add it to your Xcode project:

1. Add the framework project (located in `SMARTFramework-ios/SMARTFramework/SMARTFramework.xcodeproj`), **not** the workspace at the top level, to your Xcode workspace.

2. Tell your App to link with the necessary frameworks and libraries:  
	Open your project's build settings, under "Link Binary With Libraries" add:
	
	`libSMART.a`  
	`Security.framework`  
	`libxml2.dylib`

3. Make sure the compiler finds the header files:  
	Open your project's build settings, look for **User Header Search Paths** (USER_HEADER_SEARCH_PATHS), and add:
	
	`$(BUILT_PRODUCTS_DIR)`, with _recursive_ checked

4. The linker needs an additional flag:  
	Still in your project's build settings, look for **Other Linker Flags** (OTHER_LDFLAGS), and add:
	
	`-ObjC`  
	
	This must be added so the framework can be used as a static library, otherwise class categories will not work and your app will crash.

5. You will have to provide initial server settings in the configuration file, but you can always change the properties in code later on (e.g. if your App can connect to different servers).  
	Copy the file `Config-default.h` in the **framework** project (not your own app) to `Config.h` and adjust it to suit your needs. The setting names should define NSStrings and are named:
	- `kSMARTAPIBaseURL`  (The Server URL)
	- `kSMARTAppId`  (The App id)
	- `kSMARTConsumerKey`  (Your consumer key)
	- `kSMARTConsumerSecret`  (Your consumer secret)

6. Add `Config.h` to the Indivo Framework target. (In the default project Xcode should already know the file but show it in red because it's not in the repository. As soon as you create it, Xcode should find it and you're all good).

7. In your code, include the header files (where needed) as user header files:

	    import "SMServer.h"
	    import "SMARTObjects.h"

You are now ready to rumble!

> **Note:** The first time the framework is built it will download and compile the [Redland] C libraries for you. This may take some time and Xcode will not show any progress, just be patient.


Using the Framework
-------------------


### Instantiating a server handle ###

Make your app delegate (or some other class) the server delegate and instantiate a `SMServer` object:  

	SMServer *smart = [SMServer serverWithDelegate:<# your server delegate #>];
	
Make sure you implement the required delegate methods in your server delegate! This **smart** instance is now your handle to the SMART container.


### Selecting a record ###
	
Add a button to your app which calls `SMServer`'s `selectRecord:` method when tapped. Like all server methods in the framework, this method receives a callback once the operation completed. If record selection was successful, the `activeRecord` property on your server instance will be set (an object of class `SMRecord`) and you can use the activeRecord object to fetch documents for this record.

Here's an example that makes the app display the record-selection page with the login screen delivered by your server and, upon completion, alerts an error (if there is one) and does nothing otherwise:

```objective-c
[self.smart selectRecord:^(BOOL userDidCancel, NSString *errorMessage) {

    // there was an error selecting the record
    if (errorMessage) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to connect"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }

    // did successfully select a record
    else if (!userDidCancel) {
        // do something useful!
    }
}];
```


### Retrieving items ###

There are several calls available for the `SMRecord` instance, for example to get all medications of a record (assuming the user has already selected a record as shown above):

```objective-c
[self.smart.activeRecord getMedications:^(BOOL success, NSDictionary *userInfo) {
    if (!success) {
        NSString *errMsg = [[userInfo objectForKey:INErrorKey] localizedDescription];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to connect"
                                                        message:errMsg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        NSArray *meds = [userInfo objectForKey:INResponseArrayKey];
        // You have now got SMMedication objects in that array
    }
}];
```


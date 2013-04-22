SMART iOS Framework
===================

These are the developer instructions on how to use [SMARTFramework], an iOS framework to interface with a **[SMART container][smart]**. Make sure to check out
the **[medications sample app][medsample]**.

### Requirements ###

- #### Objective-C ####
The SMART Framework is an Objective-C framework using **ARC** ([Automatic Reference Counting][arc]), requiring **iOS 5.0 or greater**. It also uses some of the
new Objective-C language features which means you must use **Xcode 4.4** or later. You can use it as a static library (or directly import the code files into
your App project) as documented below.  
The framework utilizes a fork of [MPOAuth], an OAuth framework by Karl Adam (matrixPointer), and an Objective-C wrapper around [Redland], an RDF library,
originally created by Rene Puls and now maintaned by Pascal Pfiffner.

- #### SMART Container ####
You need a [SMART container] running version 0.6 or above

[smartframework]: https://github.com/chb/SMARTFramework-ios
[medsample]: https://github.com/chb/SMARTMedSample-ios
[smart]: http://www.smartplatforms.org/
[arc]: http://clang.llvm.org/docs/AutomaticReferenceCounting.html
[mpoauth]: https://github.com/chb/MPOAuth
[redland]: https://github.com/p2/Redland-ObjC
[smart container]: https://github.com/chb/smart_server


Technical Documentation
-----------------------

The code is documented using [appledoc] and the **[documentation is available online][docs]**. You can also build the documentation yourself, which will
install a Docset that is available from within Xcode.

To build the documentation yourself install appledoc as follows (or via [Homebrew]). After installing you can run the `SMART iOS Documentation` target right
from within Xcode.

    $ cd SMARTFramework-ios/
    $ git clone git://github.com/tomaz/appledoc.git
    $ cd appledoc
    $ ./install-appledoc.sh -b /usr/local/bin -t ~/Library/Application\ Support/appledoc

Note that this assumes that you have write permissions for `/usr/local`, if not you may need to issue this command as root with `sudo`.

As of this writing I'm still waiting for appledoc 3.0 to be released. It will add support for the `///<` property documentation style used in core parts of the
framework, version 2.0 will therefore not document some of the properties I'm afraid.

After installing appledoc and running the documentation target the documentation is available from within Xcode, just `ALT`-click any keyword like you would do
with standard Cocoa keywords.

[docs]: http://chb.github.com/SMARTFramework-ios/
[appledoc]: http://gentlebytes.com/appledoc/
[homebrew]: http://mxcl.github.com/homebrew/


Getting the Framework
---------------------

I'll be assuming that you want to add the framework to your own project. The best way to get the framework is to check out the project via **[GIT]**, and I'm
assuming you are using git for your own project as well. If you are not then substitute `git clone` for _git submodule add_ at the second step below. Open
Terminal and execute:

    $ cd YourApp
	$ git submodule add git://github.com/chb/SMARTFramework-ios.git
    $ cd SMARTFramework-ios
    $ git submodule init
    $ git submodule update

You now have the latest source code of the framework as well as the subprojects used therein. From now on you can just update to the latest source version with:

    $ cd SMARTFramework-ios
    $ git pull
    $ git submodule update --init --recursive


[git]: http://git-scm.com/


Server Side Setup
-----------------

Apps must be registered server-side with an app manifest. Here is an example app manifest which you could use for your own App:

```javascript
{
  "name" : "My iOS App",
  "description" : "A great iOS app",
  "author" : "Ms. Awesomeness",
  "id" : "my-ios-app@apps.smartplatforms.org",
  "version" : "1.0",
  "smart_version": "0.6",
  
  "mode" : "ui",
  "standalone": true,
  "scope" : "record",
  
  "index" :  "smart-app:///did_select_record",
  "oauth_callback": "smart-app:///did_receive_verifier",
  "icon" :  "http://apiverifier.smartplatforms.org/static/images/icon.png"
}
```

You can run your app against our sandbox, located at `http://sandbox-api-v06.smartplatforms.org` by using these OAuth credentials:

* app id: `my-ios-app@apps.smartplatforms.org`
* key: `my-ios-app@apps.smartplatforms.org`
* secret: `smartapp-secret`

Be aware that multiple developers may use these credentials, so if you are writing data (e.g. to the scratchpad) that data may get overwritten or deleted. For
more information about server side setup see the [SMART documentation][smart-doc].

[smart-doc]: http://docs-v06.smartplatforms.org


Framework Setup
---------------

Follow these steps to set your app up:

1. Add the framework project `SMARTFramework.xcodeproj` to your Xcode workspace.

2. Tell your App to link with the necessary frameworks and libraries:
	Open your project's build settings, under **Link Binary With Libraries** add:

	`libSMART.a`  
	`Security.framework`  
	`libxml2.dylib`

3. In the build settings look for **Header Search Paths** (USER_HEADER_SEARCH_PATHS) and **User Header Search Paths** (HEADER_SEARCH_PATHS) and add:
	
    `"$(PROJECT_DIR)"`, with _recursive_ enabled
    
    This should point to the directory (its parent is also fine, as is the case here) where the SMART framework resides. I'm assuming it's a subdirectory of
	your app, if it's not adjust the path accordingly.

4. Still in your project's build settings, look for **Other Linker Flags** (OTHER_LDFLAGS), and add:

	`-ObjC`

	This must be added so the framework can be used as a static library, otherwise class categories will not work and your app will crash.

5. You will have to provide **initial server settings** in the configuration file, but you can always change the properties in code later on (e.g. if your App
   can connect to different servers).
   Copy the file `Config-default.h` in the **framework** project (not your own app) to `Config.h` and adjust it to suit your needs. The defaults work for our
   developer sandbox. The settings are:

   - `kSMARTAPIBaseURL`  (The Server URL)
   - `kSMARTAppId`  (The App id)
   - `kSMARTConsumerKey`  (Your consumer key)
   - `kSMARTConsumerSecret`  (Your consumer secret)

6. In your code, include the header files (where needed) as user header files:

	    import "SMServer.h"
	    import "SMARTObjects.h"

You are now ready to rumble!

> **Note:** The first time the framework is built it will download and compile the [Redland] C libraries for you. This may take some time and Xcode will not
> show any progress, just be patient.

> **Note:** Xcode, after building the Redland C libraries for the first time, may not find the redland headers. Simply close the project and re-open it again.


Using the Framework
-------------------


### Instantiating a server handle ###

Make your app delegate (or some other class) the server delegate and instantiate a `SMServer` object:  

	SMServer *smart = [SMServer serverWithDelegate:<# your server delegate #>];
	
Make sure you implement the required delegate methods in your server delegate! This **smart** instance is now your handle to the SMART container.


### Selecting a record ###
	
Add a button to your app which calls `SMServer`'s `selectRecord:` method when tapped. Like all server methods in the framework, this method receives a callback
once the operation completed. If record selection was successful, the `activeRecord` property on your server instance will be set (an object of class
`SMRecord`) and you can use the `activeRecord` object to fetch documents for this record.

Here's an example that makes the app display the record-selection page with the login screen delivered by your server and, upon completion, alerts an error (if
there is one) and does nothing otherwise:

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

There are several calls available for the `SMRecord` instance, for example to get all medications of a record (assuming the user has already selected a record
as shown above):

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

You can see the available convenience methods in `SMRecord+Calls.h` or, if you have built the documentation, pull up the documentation for `SMRecord`.


SMART iOS Framework
===================

These are the developer instructions on how to use [SMARTFramework][self], an iOS framework to interface with a **[SMART container][smart]**.

### Requirements ###

- #### Objective-C ####
The SMART Framework is an Objective-C framework using **ARC** ([Automatic Reference Counting][arc]), requiring **iOS 5.0 or greater**. It also uses some of the new Objective-C language features which means you must use **Xcode 4.4** or later. You can use it as a static library (or directly import the code files into your App project) as documented below.  
The framework utilizes a fork of [MPOAuth][], an OAuth framework by Karl Adam (matrixPointer), and an Objective-C wrapper around [Redland][], an RDF library, originally created by Rene Puls.

- #### SMART Container ####
You need a [SMART container] running version 0.5 or above

[self]: https://github.com/chb/SMARTFramework-ios
[smart]: http://www.smartplatforms.org/
[arc]: http://clang.llvm.org/docs/AutomaticReferenceCounting.html
[mpoauth]: https://github.com/chb/MPOAuth
[redland]: https://github.com/p2/Redland-ObjC
[smart container]: https://github.com/chb/smart_server


Technical Documentation
-----------------------

This README contains setup and a few basic usage instructions, however the code itself is fully documented using [Doxygen][] and a technical documentation is [available online][techdoc]. A Doxyfile is included so you can generate the documentation by yourself.

The easiest way to do this is to open the Doxyfile with DoxyWizard and press "Run". This will create an HTML documentation in `Docs/html` and a ready-to-build LaTeX documentation in `Docs/latex`.

#### Embedding the documentation into Xcode ####
After building the documentation like mentioned above, you just need to install it:

    $ cd SMARTFramework-ios/Docs/html
    $ make install

After you relaunch Xcode, the documentation should be available in the Organizer and can be accessed like the standard Cocoa documentation by `ALT`-clicking code parts.

[doxygen]: http://www.doxygen.org/
[techdoc]: ...


Getting the Framework
---------------------

The best way to get the framework is to check out the project via [git][]. Open Terminal, navigate to the desired directory, and execute:

    $ git clone git://github.com/chb/SMARTFramework-ios.git
    $ cd SMARTFramework-ios
    $ git submodule init
    $ git submodule update

You now have the latest source code of the framework as well as the subprojects we use and the Medications Sample App. From now on you can just update to the latest source version with:

    $ cd SMARTFramework-ios
    $ git pull
    $ git submodule update


[git]: http://git-scm.com/


Server Side Setup
-----------------

Here is an example app manifest which would be the one you want to use with the Medications Sample App:

    {
      "name" : "Medications Sample",
      "description" : "A sample iOS app showing a list of medications",
      "author" : "Pascal Pfiffner, Harvard Medical School",
      "id" : "medsample@apps.smartplatforms.org",
      "version" : "0.1",
      "smart_version": "0.5",
      
      "mode" : "ui",
      "scope" : "record",
      
      "index" :  "smart-app:///did_select_record",
      "icon" :  "http://apiverifier.smartplatforms.org/static/images/icon.png"
    }


Framework Setup
---------------

1. Add the framework project to your Xcode workspace

2. Link your App with the necessary frameworks and libraries:  
	Open your project's build settings, under "Link Binary With Libraries" add:
	
	`libSMART.a`  
	`Security.framework`  
	`libxml2.dylib`

3. Make sure the compiler finds the header files:  
	Open your project's build settings, look for **User Header Search Paths** (USER_HEADER_SEARCH_PATHS), and add:
	
	`$(BUILT_PRODUCTS_DIR)`, with *recursive* checked

4. Tell the linker where to find the redland libraryies:
	In the build settings, look for **Library Search Paths** (LIBRARY_SEARCH_PATHS) and add:

	`"$(SRCROOT)/../Redland-ObjC/Redland-source/Universal"`

	You don't need to check the _recursive_ checkbox at the left.

5. The linker needs an additional flag:  
	Still in your project's build settings, look for **Other Linker Flags** (OTHER_LDFLAGS), and add:
	
	`-ObjC`  
	
	This must be added so the framework can be used as a static library, otherwise class categories will not work and your app will crash.

6. You will have to provide initial server settings in the configuration file, but you can always change the properties in code later on (e.g. if your App can connect to different servers).  
	Copy the file `Config-default.h` in the **framework** project (not your own app) to `Config.h` and adjust it to suit your needs. The setting names should define NSStrings and are named:
	- `kSMARTFrameworkServerURL`  (The Server URL)
	- `kSMARTFrameworkAppId`  (The App id)
	- `kSMARTFrameworkConsumerKey`  (Your consumerKey)
	- `kSMARTFrameworkConsumerSecret`  (Your consumerSecret)

7. Add `Config.h` to the Indivo Framework target. (In the default project Xcode should already know the file but show it in red because it's not in the repository. As soon as you create it, Xcode should find it and you're all good).

8. In your code, include the header files (where needed) as user header files:

		import "SMServer.h"
		import "SMARTObjects.h"

You are now ready to go!


Using the Framework
-------------------



### Instantiating a server handle ###

Make your app delegate (or some other class) the server delegate and instantiate a `SMServer` object:  

	SMServer *smart = [SMServer serverWithDelegate:<# your server delegate #>];
	
Make sure you implement the required delegate methods in your server delegate! This **smart** instance is now your connection to the SMART container.


### Selecting a record ###
	
Add a button to your app which calls `SMServer`'s `selectRecord:` method when tapped. Like all server methods in the framework, this method receives a callback once the operation completed. If record selection was successful, the `activeRecord` property on your server instance will be set (an object of class `SMRecord`) and you can use the activeRecord object to fetch documents for this record.

Here's an example that makes the app display the record-selection page with the login screen delivered by your server and, upon completion, alerts an error (if there is one) and does nothing otherwise:

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


### Retrieving items ###

There are several calls available for the `SMRecord` instance, for example to get all medications of a record (assuming the user has already selected a record as shown above):

    [self.smart.activeRecord getMedications:^(BOOL success, NSDictionary *userInfo) {
    	if (!success) {
    		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to connect"
    											    		message:[[userInfo objectForKey:INErrorKey] localizedDescription]
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


Building the Documentation
--------------------------

The code is documented using [appledoc]. If you want to compile the documentation it's best if you grab appledoc from GitHub, build and install it and then run the `SMART iOS Documentation` target right from within Xcode:

    $ cd SMARTFramework-ios/
    $ git clone git://github.com/tomaz/appledoc.git
    $ cd appledoc
    $ ./install-appledoc.sh -b /usr/local/bin -t ~/Library/Application\ Support/appledoc

Note that this assumes that you have write permissions for `/usr/local`, if not you may need to issue this command as root with `sudo`.

After that, the documentation is available from within Xcode, just ALT+click any keyword like you would do with standard Cocoa keywords.


[appledoc]: http://gentlebytes.com/appledoc/



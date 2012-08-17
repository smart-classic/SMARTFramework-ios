SMART iOS Framework
===================

These are the developer instructions on how to use [SMARTFramework][self], an iOS framework to interface with a **[SMART container][smart]**.

### Requirements ###

- #### Objective-C ####
The SMART Framework is an Objective-C framework using **ARC** ([Automatic Reference Counting][arc]), requiring **iOS 5.0 or greater**. It also uses some of the new Objective-C language features which means you must use **Xcode 4.4** or later. You can use it as a static library (or directly import the code files into your App project) as documented below.  
The framework utilizes a fork of [MPOAuth][], an OAuth framework by Karl Adam (matrixPointer), and an Objective-C wrapper around [Redland][], an RDF library, originally created by Rene Puls.

- #### SMART Container ####
For most operations the framework talks to the [Indivo Server][] directly, however for login and record selection needs to talk to the corresponding [Indivo UI Server][]. Indivo X 1.0 will support Apps running the framework out of the box.

[self]: https://github.com/chb/SMARTFramework-ios
[smart]: http://www.smartplatforms.org/
[arc]: http://clang.llvm.org/docs/AutomaticReferenceCounting.html
[mpoauth]: https://github.com/chb/MPOAuth
[redland]: https://github.com/p2/Redland-ObjC
[indivo server]: https://github.com/chb/indivo_server
[indivo ui server]: https://github.com/chb/indivo_ui_server


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
		import "SMARTDocuments.h"

You are now ready to go!


Using the Framework
-------------------

...


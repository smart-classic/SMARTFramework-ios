Welcome to the API documentation of the SMART framework for iOS.

Setup Instructions
------------------

Instructions an how to setup the framework can be found in README.md also provided with the project, which can be viewed nicely formatted on our github page:
https://github.com/chb/SMARTFramework-ios

Framework Usage
---------------

At the heart of the framework are these three classes:

**SMServer** – **SMRecord** – **SMObject**


### SMServer ###

You instantiate a `SMServer` object to get a handle to your SMART server and the records that live on the server. The server object handles most of the behind-
the-scenes tasks, for a framework user you will mostly use the `-selectRecord:` method.


### SMRecord ###

The server returns a `SMRecord` object as soon as the user has selected a patient record to work with. Take a look at all the methods that a record instance
supports to see how you can GET and POST documents.


### SMObject ###

All the data models such as a medication or allergy that SMART supports are subclasses of `SMObject`. Since SMART deals with RDF, behind every instance of a
SMObject subclass is an RDF graph. But fear not, you do not have to touch any RDF related internals to work with those objects, it has all been abstracted away
from you.

Most of the time you will work with objects that you have retrieved from the server and will only read its properties, however the framework supports
reassigning properties and will update the RDF graph in the background. This process has not been extensively tested,
[please report](https://github.com/chb/SMARTFramework-ios/issues) any issues that you may find.

Happy coding!

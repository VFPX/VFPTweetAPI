# VFPTweetAPI
This API was formerly named VFPTwitterAPI. The API was renamed as Twitter doesn't allow "twitter" in 
third party app names.

VFPTweetAPI is MS Visual Foxpro implementation of the twitter API. It's intended both for usage in native FoxPro and as COM Server for use in any COM/OLE enabled programming language.

## License
VFPTwitterAPI is released under the GNU Library General Public License (LGPL).
See http://vfptweetapi.codeplex.com/license

## Instructions
This version of the VFPTweetAPI contains OAuth authentication and has its own consumer key and consumer secret, which Twitter provides. You can use it right away, just be warned, that you share this key and secret with all other VFPTweetAPI users. This means you share a limited amount of 100 requests per hour with other developers.

## ATTENTION PLEASE!
It's recommended to acquire your own consumer key/secret value pair to have 100 requests per hour for yourself. If you don't do this, you do not only share this limit, you will also not have control about the key/secret, which I can and will change once in a while, especially with new releases of the API. 

The consumer key and secret are bound to a Twitter Desktop- or Webapp. Please login to Twitter and navigate to [http://twitter.com/oauth_clients/new](http://twitter.com/oauth_clients/new) to register your own Twitter App.

After you registered an app you'll find your own Consumer key and secret with your own rate limit 
at [http://twitter.com/oauth_clients/](http://twitter.com/oauth_clients/)

Edit liboauth.prg and enter your Key and Secret there to test the API with OAuth authentication.

## History

Release 0.1
------------
vfptwitterapi.prg

A first prealpha version

Release 0.2
-----------
<pre>
VFPTwitterAPI.zip  
   VFPTwitterAPI  
      data folder  
         metadata  
            metadata database  
            paths table  
            libsandprgs table  
      libs folder  
         projecthooks library  
      prgs folder  
         libbase - base classes  
         libhttprequests - http request classes  
         liboauth - OAuth classes (OAuth consumer methods only)  
                    This lib is using Craig S. Boyd's vfpencryption71.fll  
         libvfptwitterapi - the core VFPTwitterAPI class  
         _loader - loads libs and prgs  
         _test - your starting point for testing the API  
         __packclass - a utility to PACK vcx and scx files to get rid of memo bloat of source code  
           
         
      vfpencryption71.fll (for SHA1 Hash of HMAC-SHA1 OAuth signatures)  
      projecthook project - for modifying the projecthook used in the main project  
      vfptwitterapi project - main project  
</pre>

Release 0.3
-----------
VFPTwitterAPI renamed to VFPTweetAPI, as Twitter doesn't allow apps with twitter in their names. And the VFPTweetAPI is now an 'app' registered via [http://twitter.com/apps/new](http://twitter.com/apps/new). The consequence is that the VFPTweetAPI and now have a seperate ConsumerKey and ConsumerSecret. You can use the API right away without acquiring such a key pair via an app registration.

<pre>
VFPTweetAPI.zip
   VFPTweetAPI
      data folder
         metadata - this folder and its files are created when first opening the pjx
            metadata database
            paths table
            libsandprgs table
      docs folder
         tables.txt - documentation of the VFPTweetAPI tables the libpersist package creates
      images
         foxtwitter.png - Logo of the VFPTweetAPI
      include
         winapi_constants.h - Some winapi constants

      libs folder
         projecthooks library
      prgs folder
         libbase - base classes
         libendecode - package with some encoding functions. Mainly urlencode and HMAC-SHA1 hashing
         libhttprequest - package for http requests

         libfilesystem - package with file system functiones, eg to determine the local app data folder
         libguid - package with some guid functions, mainly used by libfilesystem for KnownFolderIDs
         liboauth - package with OAuth classes (OAuth consumer methods)
         libpersist - package for persisting VFPTweetAPI data
         libtime - package with a time functions to determine UTCTime needed for twitter requests
         libvfptwitterapi - the core VFPTweetAPI class
         libwinapi - package with some Windows API declarations
         _loader - loads libs and prgs
         _main - empty main.prg needed for build of the project only.
===>     _test - your starting point for a first test of the API
         __packclass - a utility to PACK vcx and scx files to get rid of memo bloat of source code
           
         
      vfpencryption71.fll (for SHA1 Hash of HMAC-SHA1 OAuth signatures)
      projecthook project - for modifying the projecthook used in the main project
      vfptweetapi project - main project
      vftweetapi.dll - COM server (multthreaded DLL) of the VFPTweetAPI
</pre>

Release 0.3.1
-------------
Added a simple Testform and Storing Users and Statuses in libpersist. A compiled version is included. You need VFP9 or the runtime installer ftp://ftp.prolib.de/Public/VFP9SP2RT.exe to run that.

<pre>
VFPTweetAPI.zip
   VFPTweetAPI
      data folder
         metadata - this folder and it's files are included empty
                    Data is added via a projecthook also included as projecthook.pjx
            metadata database
            paths table
            libsandprgs table
      docs folder
         tables.txt - documentation of the VFPTweetAPI tables the libpersist package creates
      images
         foxtwitter.png - Logo of the VFPTweetAPI
         Sign-in-with-Twitter-darker.png - official Twitter image for a sign in button
      include
         winapi_constants.h - Some winapi constants
         config.fpw - a foxpro config file

      libs folder
         _controls library  - some basic foxpro controls
         _forms library - some base/abstract form classes
         forms library - the library containing the test form
         projecthooks library
      prgs folder
         libbase - base classes
         libendecode - package with some encoding functions. Mainly urlencode and HMAC-SHA1 hashing
         libhttprequest - package for http requests

         libfilesystem - package with file system functiones, eg to determine the local app data folder
         libguid - package with some guid functions, mainly used by libfilesystem for KnownFolderIDs
         liboauth - package with OAuth classes (OAuth consumer methods)
         libpersist - package for persisting VFPTweetAPI data
         libtime - package with a time functions to determine UTCTime needed for twitter requests
         libvfptwitterapi - the core VFPTweetAPI class
         libwinapi - package with some Windows API declarations
         _loader - loads libs and prgs
         _main - empty main.prg needed for build of the project only.
===>     _test - your starting point for a first test of the API
         __packclass - a utility to PACK vcx and scx files to get rid of memo bloat of source code
           
         
      vfpencryption71.fll (for SHA1 Hash of HMAC-SHA1 OAuth signatures)
      projecthook project - for modifying the projecthook used in the main project
      vfptweetapi project - main project
      vftweetapi.dll - COM server (multthreaded DLL) of the VFPTweetAPI
</pre>
(C) 2009 Olaf Doschke, VFP MVP 2007-2009
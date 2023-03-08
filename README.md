# PhoneGap / Cordova Social Sharing plugin

[![NPM version][npm-image]][npm-url]
[![Downloads][downloads-image]][npm-url]
[![TotalDownloads][total-downloads-image]][npm-url]
[![Twitter Follow][twitter-image]][twitter-url]

[npm-image]:http://img.shields.io/npm/v/cordova-plugin-x-socialsharing.svg
[npm-url]:https://npmjs.org/package/cordova-plugin-x-socialsharing
[downloads-image]:http://img.shields.io/npm/dm/cordova-plugin-x-socialsharing.svg
[total-downloads-image]:http://img.shields.io/npm/dt/cordova-plugin-x-socialsharing.svg?label=total%20downloads
[twitter-image]:https://img.shields.io/twitter/follow/eddyverbruggen.svg?style=social&label=Follow%20me
[twitter-url]:https://twitter.com/eddyverbruggen

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=eddyverbruggen%40gmail%2ecom&lc=US&item_name=cordova%2dplugin%2dsocialsharing&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted)
Every now and then kind folks ask me how they can give me all their money. So if you want to contribute to my pension fund, then please go ahead :)

> Version 6.0.0 is compatible with Android X. See [this issue](https://github.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin/pull/1039) for details. 5.6.8 is the last version before 6.0.0, so be sure to pick that if you run into Android X-related issues.

## 0. Index

1. [Description](#1-description)
2. [Screenshots](#2-screenshots)
3. [Installation](#3-installation)
4. [Usage on iOS and Android](#4-usage-on-ios-and-android)
5. [Web Share API](#5-web-share-api)
6. [Usage on Windows Phone](#6-usage-on-windows-phone)
7. [Share-popover on iPad](#7-share-popover-on-ipad)
8. [Whitelisting on iOS](#8-whitelisting-on-ios)
9. [NSPhotoLibraryUsageDescription on iOS](#9-nsphotolibraryusagedescription-on-ios)
10. [Import Types into an Ionic Angular Project](#10-import-types-into-an-ionic-angular-project)

## 1. Description

This plugin allows you to use the native sharing window of your mobile device.

* Share text, a link, a images (or other files like pdf or ics). Subject is also supported, when the receiving app supports it.
* Supports sharing files from the internet, the local filesystem, or from the www folder.
* You can skip the sharing dialog and directly share to Twitter, Facebook, or other apps.
* Compatible with [Cordova Plugman](https://github.com/apache/cordova-plugman).
* Officially supported by [PhoneGap Build](https://build.phonegap.com/plugins).

## 2. Screenshots
iOS 7 (iPhone)

![ScreenShot](https://raw.githubusercontent.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin/master/screenshots/screenshot-ios7-share.png)

Sharing options are based on what has been setup in the device settings

![ScreenShot](https://raw.githubusercontent.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin/master/screenshots/screenshots-ios7-shareconfig.png)

iOS 7 (iPad) - a popup like this requires [a little more effort](#4c-share-popover-on-ipad)

![ScreenShot](https://raw.githubusercontent.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin/master/screenshots/screenshot-ios7-ipad-share.png)

iOS 6 (iPhone)

![ScreenShot](https://raw.githubusercontent.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin/master/screenshots/screenshot-ios6-share.png)

Android

![ScreenShot](https://raw.githubusercontent.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin/master/screenshots/screenshot-android-share.png)

Windows Phone 8

![ScreenShot](https://raw.githubusercontent.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin/master/screenshots/screenshot-wp8-share.jpg)

#### Alternative ShareSheet (iOS only, using the [Cordova ActionSheet plugin](https://github.com/EddyVerbruggen/cordova-plugin-actionsheet))

![ScreenShot](https://raw.githubusercontent.com/EddyVerbruggen/cordova-plugin-actionsheet/master/screenshots/ios/ios-share.png)

## 3. Installation

### Automatically (CLI / Plugman)
SocialSharing is compatible with [Cordova Plugman](https://github.com/apache/cordova-plugman), compatible with [PhoneGap 3.0 CLI](http://docs.phonegap.com/en/3.0.0/guide_cli_index.md.html#The%20Command-line%20Interface_add_features), here's how it works with the CLI:

```
$ phonegap local plugin add https://github.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin.git
```

or with Cordova CLI, from npm:
```
$ cordova plugin add cordova-plugin-x-socialsharing
$ cordova prepare
```

SocialSharing.js is brought in automatically. There is no need to change or add anything in your html.
**However, you do need to add the feature to your config.xml.**

```xml
<!-- These lines should have been added by cordova-cli automatically: -->
<plugin name="cordova-plugin-x-socialsharing" spec="^5.4.4">
  <variable name="ANDROID_SUPPORT_V4_VERSION" value="24.1.1+" />
</plugin>

<!-- Add the following: -->
<!-- for iOS -->
<feature name="SocialSharing">
  <param name="ios-package" value="SocialSharing" />
</feature>
<!-- for Android (you will find one in res/xml) -->
<feature name="SocialSharing">
  <param name="android-package" value="nl.xservices.plugins.SocialSharing" />
</feature>
<!-- for Windows Phone -->
<feature name="SocialSharing">
  <param name="wp-package" value="SocialSharing"/>
</feature>
```

### Manually

1\. Add the following xml to all the `config.xml` files you can find:
```xml
<!-- for iOS -->
<feature name="SocialSharing">
  <param name="ios-package" value="SocialSharing" />
</feature>
```
```xml
<!-- for Android (you will find one in res/xml) -->
<feature name="SocialSharing">
  <param name="android-package" value="nl.xservices.plugins.SocialSharing" />
</feature>
```
```xml
<!-- for Windows Phone -->
<feature name="SocialSharing">
  <param name="wp-package" value="SocialSharing"/>
</feature>
```

For sharing remote images (or other files) on Android, the file needs to be stored locally first, so add this permission to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

For iOS, you'll need to add the `Social.framework` and `MessageUI.framework` to your project. Click your project, Build Phases, Link Binary With Libraries, search for and add `Social.framework` and `MessageUI.framework`.

2\. Grab a copy of SocialSharing.js, add it to your project and reference it in `index.html`:
```html
<script type="text/javascript" src="js/SocialSharing.js"></script>
```

3\. Download the source files for iOS and/or Android and copy them to your project.

iOS: Copy `SocialSharing.h` and `SocialSharing.m` to `platforms/ios/<ProjectName>/Plugins`

Android: Copy `SocialSharing.java` to `platforms/android/src/nl/xservices/plugins` (create the folders)

Window Phone: Copy `SocialSharing.cs` to `platforms/wp8/Plugins/nl.x-services.plugins.socialsharing` (create the folders)

### PhoneGap Build

Just add the following xml to your `config.xml` to always use the latest version of this plugin (which is published to plugins.cordova.io these days):
```xml
<gap:plugin name="cordova-plugin-x-socialsharing" source="npm" />
```
or to use an older version, hosted at phonegap build:
```xml
<gap:plugin name="nl.x-services.plugins.socialsharing" version="4.3.16" />
```

SocialSharing.js is brought in automatically. Make sure though you include a reference to cordova.js in your index.html's head:
```html
<script type="text/javascript" src="cordova.js"></script>
```

## 4. Usage on iOS and Android
You can share text, a subject (in case the user selects the email application), (any type and location of) file (like an image), and a link.
However, what exactly gets shared, depends on the application the user chooses to complete the action. A few examples:
- Mail: message, subject, file.
- Twitter: message, image (other filetypes are not supported), link (which is automatically shortened if the Twitter client deems it necessary).
- Google+ / Hangouts (Android only): message, subject, link
- Flickr: message, image (an image is required for this option to show up).
- Facebook Android: sharing a message is not possible. You can share either a link or an image (not both), but a description can not be prefilled. See [this Facebook issue which they won't solve](https://developers.facebook.com/x/bugs/332619626816423/). As an alternative you can use `shareViaFacebookWithPasteMessageHint` since plugin version 4.3.4. See below for details. Also note that sharing a URL on a non standard domain (like .fail) [may not work on Android](https://github.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin/issues/253). Make sure you test this. You can use a [link shortener](https://goo.gl) to workaround this issue.
- Facebook iOS: message, image (other filetypes are not supported), link. Beware that since a Fb update in April 2015 sharing a prefilled message is no longer possible when the Fb app is installed (like Android), see #344. Alternative: use `shareViaFacebookWithPasteMessageHint`.

### Using the share sheet
It's recommended to use `shareWithOptions` as it's the most feature rich way to share stuff cross-platform.

It will also tell you if sharing to an app completed and which app that was (if that app plays nice, that is).

```js
// this is the complete list of currently supported params you can pass to the plugin (all optional)
var options = {
  message: 'share this', // not supported on some apps (Facebook, Instagram)
  subject: 'the subject', // fi. for email
  files: ['', ''], // an array of filenames either locally or remotely
  url: 'https://www.website.com/foo/#bar?a=b',
  chooserTitle: 'Pick an app', // Android only, you can override the default share sheet title
  appPackageName: 'com.apple.social.facebook', // Android only, you can provide id of the App you want to share with
  iPadCoordinates: '0,0,0,0' //IOS only iPadCoordinates for where the popover should be point.  Format with x,y,width,height
};

var onSuccess = function(result) {
  console.log("Share completed? " + result.completed); // On Android apps mostly return false even while it's true
  console.log("Shared to app: " + result.app); // On Android result.app since plugin version 5.4.0 this is no longer empty. On iOS it's empty when sharing is cancelled (result.completed=false)
};

var onError = function(msg) {
  console.log("Sharing failed with message: " + msg);
};

window.plugins.socialsharing.shareWithOptions(options, onSuccess, onError);
```

#### You can still use the older `share` method as well
Here are some examples you can copy-paste to test the various combinations:
```html
<button onclick="window.plugins.socialsharing.share('Message only')">message only</button>
<button onclick="window.plugins.socialsharing.share('Message and subject', 'The subject')">message and subject</button>
<button onclick="window.plugins.socialsharing.share(null, null, null, 'http://www.x-services.nl')">link only</button>
<button onclick="window.plugins.socialsharing.share('Message and link', null, null, 'http://www.x-services.nl')">message and link</button>
<button onclick="window.plugins.socialsharing.share(null, null, 'https://www.google.nl/images/srpr/logo4w.png', null)">image only</button>
// Beware: passing a base64 file as 'data:' is not supported on Android 2.x: https://code.google.com/p/android/issues/detail?id=7901#c43
// Hint: when sharing a base64 encoded file on Android you can set the filename by passing it as the subject (second param)
<button onclick="window.plugins.socialsharing.share(null, 'Android filename', 'data:image/png;base64,R0lGODlhDAAMALMBAP8AAP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAUKAAEALAAAAAAMAAwAQAQZMMhJK7iY4p3nlZ8XgmNlnibXdVqolmhcRQA7', null)">base64 image only</button>
// Hint: you can share multiple files by using an array as thirds param: ['file 1','file 2', ..], but beware of this Android Kitkat Facebook issue: [#164]
<button onclick="window.plugins.socialsharing.share('Message and image', null, 'https://www.google.nl/images/srpr/logo4w.png', null)">message and image</button>
<button onclick="window.plugins.socialsharing.share('Message, image and link', null, 'https://www.google.nl/images/srpr/logo4w.png', 'http://www.x-services.nl')">message, image and link</button>
<button onclick="window.plugins.socialsharing.share('Message, subject, image and link', 'The subject', 'https://www.google.nl/images/srpr/logo4w.png', 'http://www.x-services.nl')">message, subject, image and link</button>
```

Example: share a PDF file from the local www folder:
```html
<button onclick="window.plugins.socialsharing.share('Here is your PDF file', 'Your PDF', 'www/files/manual.pdf')">Share PDF</button>
```

### Sharing directly to..

#### Twitter
```html
<!-- unlike most apps Twitter doesn't like it when you use an array to pass multiple files as the second param -->
<button onclick="window.plugins.socialsharing.shareViaTwitter('Message via Twitter')">message via Twitter</button>
<button onclick="window.plugins.socialsharing.shareViaTwitter('Message and link via Twitter', null /* img */, 'http://www.x-services.nl')">msg and link via Twitter</button>
```

#### Facebook
```html
<button onclick="window.plugins.socialsharing.shareViaFacebook('Message via Facebook', null /* img */, null /* url */, function() {console.log('share ok')}, function(errormsg){alert(errormsg)})">msg via Facebook (with errcallback)</button>
```

Facebook with prefilled message - as a workaround for [this Facebook (Android) bug](https://developers.facebook.com/x/bugs/332619626816423/). BEWARE: it's against Facebooks policy to prefil the message, or even hint the user to prefill a message for them. [See this page for details.](https://developers.facebook.com/docs/apps/review/prefill)

* On Android the user will see a Toast message with a message you control (default: "If you like you can paste a message from your clipboard").
* On iOS this function used to behave the same as `shareViaFacebook`, but since 4.3.18 a short message is shown prompting the user to paste a message (like Android). This message is not shown in case the Fb app is not installed since the internal iOS Fb share widget still supports prefilling the message.
* iOS9 quirk: if you want to use this method, you need to whitelist `fb://` in your .plist file.
```html
<button onclick="window.plugins.socialsharing.shareViaFacebookWithPasteMessageHint('Message via Facebook', null /* img */, null /* url */, 'Paste it dude!', function() {console.log('share ok')}, function(errormsg){alert(errormsg)})">msg via Facebook (with errcallback)</button>
```

Whitelisting Facebook in your app's .plist:
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>fb</string>
</array>
```

#### Instagram
```html
<button onclick="window.plugins.socialsharing.shareViaInstagram('Message via Instagram', 'https://www.google.nl/images/srpr/logo4w.png', function() {console.log('share ok')}, function(errormsg){alert(errormsg)})">msg via Instagram</button>
```

Quirks:
* Instagram no longer permits prefilling a message - you can prompt the user to paste the message you've passed to the plugin because we're adding it to the clipboard for you.

iOS Quirks:
* Before trying to invoke `shareViaInstagram` please use `canShareVia('instagram'..` AND whitelist the urlscheme (see below).
* Although this plugin follows the Instagram sharing guidelines, the user may not only see Instagram in the share sheet, but also other apps that listen to the "Instagram sharing ID". Just google "com.instagram.exclusivegram" and you see what I mean.


#### WhatsApp
* Note that on iOS when sharing an image and text, only the image is shared - let's hope WhatsApp creates a proper iOS extension to fix this.
* Before using this method you may want to use `canShareVia('whatsapp'..` (see below).
```html
<button onclick="window.plugins.socialsharing.shareViaWhatsApp('Message via WhatsApp', null /* img */, null /* url */, function() {console.log('share ok')}, function(errormsg){alert(errormsg)})">msg via WhatsApp (with errcallback)</button>
```

##### Sharing directly to someone
Note that on Android you can only send a 'text' and 'url' directly to someone, so files are ignored.

###### By phone number

```html
<button onclick="window.plugins.socialsharing.shareViaWhatsAppToPhone('+31611111111', 'Message via WhatsApp', null /* img */, null /* url */, function() {console.log('share ok')})">msg via WhatsApp to phone number +31611111111</button>
```

###### By "abid" (iOS) or phone number (Android)

```html
<button onclick="window.plugins.socialsharing.shareViaWhatsAppToReceiver('101', 'Message via WhatsApp', null /* img */, null /* url */, function() {console.log('share ok')})">msg via WhatsApp for Addressbook ID 101</button>
```
The first argument on iOS needs to be the Addressbook ID (or 'abid'). You can find those abid's by using the [Cordova Contacts Plugin](https://github.com/apache/cordova-plugin-contacts).
The result in the success callback of the `find` function is a JSON array of contact objects, use the 'id' you find in those objects.
Don't pass in an image on iOS because that can't be sent to someone directly unfortunately. Message and URL are fine though.

On Android pass in the phone number of the person you want to send a message to.

#### SMS
Note that on Android, SMS via Hangouts may not behave correctly
```html
<!-- Want to share a prefilled SMS text? -->
<button onclick="window.plugins.socialsharing.shareViaSMS('My cool message', null /* see the note below */, function(msg) {console.log('ok: ' + msg)}, function(msg) {alert('error: ' + msg)})">share via SMS</button>
<!-- Want to prefill some phonenumbers as well? Pass this instead of null. Important notes: For stable usage of shareViaSMS on Android 4.4 and up you require to add at least one phonenumber! Also, on Android make sure you use v4.0.3 or higher of this plugin, otherwise sharing multiple numbers to non-Samsung devices will fail -->
<button onclick="window.plugins.socialsharing.shareViaSMS('My cool message', '0612345678,0687654321', function(msg) {console.log('ok: ' + msg)}, function(msg) {alert('error: ' + msg)})">share via SMS</button>
<!-- Need a subject and even image sharing? It's only supported on iOS for now and falls back to just message sharing on Android -->
<button onclick="window.plugins.socialsharing.shareViaSMS({'message':'My cool message', 'subject':'The subject', 'image':'https://www.google.nl/images/srpr/logo4w.png'}, '0612345678,0687654321', function(msg) {console.log('ok: ' + msg)}, function(msg) {alert('error: ' + msg)})">share via SMS</button>
```

#### Email
Code inspired by the [EmailComposer plugin](https://github.com/katzer/cordova-plugin-email-composer), note that this is not supported on the iOS 8 simulator (an alert will be shown if your try to).
```js
window.plugins.socialsharing.shareViaEmail(
  'Message', // can contain HTML tags, but support on Android is rather limited:  http://stackoverflow.com/questions/15136480/how-to-send-html-content-with-image-through-android-default-email-client
  'Subject',
  ['to@person1.com', 'to@person2.com'], // TO: must be null or an array
  ['cc@person1.com'], // CC: must be null or an array
  null, // BCC: must be null or an array
  ['https://www.google.nl/images/srpr/logo4w.png','www/localimage.png'], // FILES: can be null, a string, or an array
  onSuccess, // called when sharing worked, but also when the user cancelled sharing via email. On iOS, the callbacks' boolean result parameter is true when sharing worked, false if cancelled. On Android, this parameter is always true so it can't be used). See section "Notes about the successCallback" below.
  onError // called when sh*t hits the fan
);
```

If Facebook, Twitter, Instagram, WhatsApp, SMS or Email is not available, the errorCallback is called with the text 'not available'.

If you feel lucky, you can even try to start any application with the `shareVia` function:
```html
<!-- start facebook on iOS (same as `shareViaFacebook`), if Facebook is not installed, the errorcallback will be invoked with message 'not available' -->
<button onclick="window.plugins.socialsharing.shareVia('com.apple.social.facebook', 'Message via FB', null, null, null, function(){console.log('share ok')}, function(msg) {alert('error: ' + msg)})">message via Facebook</button>
<!-- start facebook on Android (same as `shareViaFacebook`), if Facebook is not installed, the errorcallback will be invoked with message 'not available' -->
<button onclick="window.plugins.socialsharing.shareVia('facebook', 'Message via FB', null, null, null, function(){console.log('share ok')}, function(msg) {alert('error: ' + msg)})">message via Facebook</button>
<!-- start twitter on iOS (same as `shareViaTwitter`), if Twitter is not installed, the errorcallback will be invoked with message 'not available' -->
<button onclick="window.plugins.socialsharing.shareVia('com.apple.social.twitter', 'Message via Twitter', null, null, 'http://www.x-services.nl', function(){console.log('share ok')}, function(msg) {alert('error: ' + msg)})">message and link via Twitter on iOS</button>
<!-- if you share to a non existing/supported app, the errorcallback will be invoked with message 'not available' -->
<button onclick="window.plugins.socialsharing.shareVia('bogus_app', 'Message via Bogus App', null, null, null, function(){console.log('share ok')}, function(msg) {alert('error: ' + msg)})">message via Bogus App</button>
```

What can we pass to the `shareVia` function?
* iOS: You are limited to 'com.apple.social.[facebook | twitter | sinaweibo | tencentweibo]'. If an app does not exist, the errorcallback is invoked and iOS shows a popup message asking the user to configure the app.
* Android: Anything that would otherwise appear in the sharing dialoge (in case the `share` function was used. Pass a (part of the) packagename of the app you want to share to. The `shareViaFacebook` function for instance uses `com.facebook.katana` as the packagename fragment. Things like `weibo`, `pinterest` and `com.google.android.apps.plus` (Google+) should work just fine.

You can even test if a sharing option is available with `canShareVia`!
You'll need to pass everything you want to share, because (at least on Android) some apps may only become available when an image is added.
The function will invoke the successCallback when it can be shared to via `shareVia`, and the errorCallback if not. As a bonus on Android, the errorCallback contains a JSON Array of available packages you can pass to shareVia.
You can even specify the activity if the app offers multiple sharing ways, passing 'packageName/activityName'. (for example, WeChat, passing 'com.tencent.mm' or 'com.tencent.mm/com.tencent.mm.ui.tools.ShareImgUI' to share to chat, passing 'com.tencent.mm/com.tencent.mm.ui.tools.ShareToTimeLineUI' to share to moments).

```html
<button onclick="window.plugins.socialsharing.canShareVia('com.tencent.mm/com.tencent.mm.ui.tools.ShareToTimeLineUI', 'msg', null, img, null, function(e){alert(e)}, function(e){alert(e)})">is WeChat available on Android?</button>
<button onclick="window.plugins.socialsharing.canShareVia('com.apple.social.facebook', 'msg', null, null, null, function(e){alert(e)}, function(e){alert(e)})">is facebook available on iOS?</button>
// this one requires whitelisting of whatsapp:// on iOS9 in your .plist file
<button onclick="window.plugins.socialsharing.canShareVia('whatsapp', 'msg', null, null, null, function(e){alert(e)}, function(e){alert(e)})">is WhatsApp available?</button>
<button onclick="window.plugins.socialsharing.canShareVia('sms', 'msg', null, null, null, function(e){alert(e)}, function(e){alert(e)})">is SMS available?</button>
<button onclick="window.plugins.socialsharing.canShareVia('instagram', 'msg', null, null, null, function(e){alert(e)}, function(e){alert(e)})">is Instagram available?</button>
<!-- Email is a different beast, so I added a specific method for it -->
<button onclick="window.plugins.socialsharing.canShareViaEmail(function(e){alert(e)}, function(e){alert(e)})">is Email available?</button>
```

Want to share images from a local folder (like an image you just selected from the CameraRoll)?
```javascript
// use a local image from inside the www folder:
window.plugins.socialsharing.share(null, null, 'www/image.gif', null); // success/error callback params may be added as 5th and 6th param
// .. or a local image from anywhere else (if permitted):
// local-iOS:
window.plugins.socialsharing.share(null, null, '/Users/username/Library/Application Support/iPhone/6.1/Applications/25A1E7CF-079F-438D-823B-55C6F8CD2DC0/Documents/.nl.x-services.appname/pics/img.jpg');
// local-iOS-alt:
window.plugins.socialsharing.share(null, null, 'file:///Users/username/Library/Application Support/iPhone/6.1/Applications/25A1E7CF-079F-438D-823B-55C6F8CD2DC0/Documents/.nl.x-services.appname/pics/img.jpg');
// local-Android:
window.plugins.socialsharing.share(null, null, 'file:///storage/emulated/0/nl.xservices.testapp/5359/Photos/16832/Thumb.jpg');
// .. or an image from the internet:
window.plugins.socialsharing.share(null, null, 'http://domain.com/image.jpg');
```

If you can't get the plugin to work, have a look at [this demo project](https://github.com/EddyVerbruggen/X-Services-PhoneGap-Build-Plugins-Demo).

#### Notes about the successCallback (you can just ignore the callbacks if you like)
The plugin passes a boolean to the successCallback to let the app know whether or not content was actually shared, or the share widget was closed by the user.
On iOS this works as expected (except for Facebook, in case the app is installed), but on Android some sharing targets may return false, even though sharing succeeded. This is not a limitation of the plugin, it's the target app which doesn't play nice.
To make it more confusing, when sharing via SMS on Android, you'll likely always have the successCallback invoked. Thanks Google.

#### Sharing multiple images (or other files)
You can pass an array of files to the share and shareVia functions.

```js
// sharing multiple images via Facebook (you can mix protocols and file locations)
window.plugins.socialsharing.shareViaFacebook(
  'Optional message, may be ignored by Facebook app',
  ['https://www.google.nl/images/srpr/logo4w.png','www/image.gif'],
  null);

// sharing a PDF and an image
window.plugins.socialsharing.share(
  'Optional message',
  'Optional title',
  ['www/manual.pdf','https://www.google.nl/images/srpr/logo4w.png'],
  'http://www.myurl.com');
```

Note that a lot of apps support sharing multiple files, but Twitter just doesn't accept more that one file.

#### Saving images to the photo album (iOS only currently)
You can save an array of images to the camera roll:

```js
window.plugins.socialsharing.saveToPhotoAlbum(
  ['https://www.google.nl/images/srpr/logo4w.png','www/image.gif'],
  onSuccess, // optional success function
  onError    // optional error function
);
```

#### iOS quirk (with camera plugin)
When using this plugin in the callback of the Phonegap camera plugin, wrap the call to `share()` in a `setTimeout()`.
The share widget has the same limitation as the alert dialogue [mentioned in the Phonegap documentation](http://docs.phonegap.com/en/2.9.0/cordova_camera_camera.md.html#camera.getPicture_ios_quirks).

#### Excluding some options from the widget
If you want to exclude (for example) the assign-to-contact and copy-to-pasteboard options, add this to your main plist file:

```xml
<key>SocialSharingExcludeActivities</key>
<array>
  <string>com.apple.UIKit.activity.AssignToContact</string>
  <string>com.apple.UIKit.activity.CopyToPasteboard</string>
</array>
```

Here's the list of available activities you can disable :

 - com.apple.UIKit.activity.PostToFacebook
 - com.apple.UIKit.activity.PostToTwitter
 - com.apple.UIKit.activity.PostToFlickr
 - com.apple.UIKit.activity.PostToWeibo
 - com.apple.UIKit.activity.PostToVimeo
 - com.apple.UIKit.activity.TencentWeibo
 - com.apple.UIKit.activity.Message
 - com.apple.UIKit.activity.Mail
 - com.apple.UIKit.activity.Print
 - com.apple.UIKit.activity.CopyToPasteboard
 - com.apple.UIKit.activity.AssignToContact
 - com.apple.UIKit.activity.SaveToCameraRoll
 - com.apple.UIKit.activity.AddToReadingList
 - com.apple.UIKit.activity.AirDrop

## 5. Web Share API

Chrome introduced the [Web Share API](https://github.com/WICG/web-share) to share data:

```js
navigator.share({
  'title': 'Optional title',
  'text': 'Optional message',
  'url': 'http://www.myurl.com'
}).then(function() {
  console.log('Successful share');
}).catch(function(error) {
  console.log('Error sharing:', error)
});
```

It doesn't provide all the options that the other share methods do but it is spec compliant.

## 6. Usage on Windows Phone
The available methods on WP8 are: `available`, `canShareViaEmail`, `share`, `shareViaEmail` and `shareViaSMS`.
Currently the first two always return true, but this may change in the future in case I can find a way to truly detect the availability.

The `share` function on WP8 supports two flavours: message only, or a combination of message, title and link.

Beware: for now please pass null values for all non used attributes, like in the examples below.

Sharing a message:
```html
<button onclick="window.plugins.socialsharing.share('Message only', null, null, null)">message only</button>
```

Sharing a link:
```html
<button onclick="window.plugins.socialsharing.share('Optional message', 'Optional title', null, 'http://www.x-services.nl')">message, title, link</button>
```

Sharing an image (only images from the internet are supported). If you pass more than one image as an array, only the first one is used:
```html
<button onclick="window.plugins.socialsharing.share('Optional message', 'Optional title', 'https://www.google.nl/images/srpr/logo4w.png', null)">image only</button>
```

## 7. Share-popover on iPad

> This no longer works since plugin version 5.5.0, see [this issue](https://github.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin/issues/1052).

Carlos Sola-Llonch, a user of this plugin, pointed me at an [iOS document](https://developer.apple.com/library/ios/documentation/uikit/reference/UIActivityViewController_Class/Reference/Reference.html)
stating "On iPad, you must present the view controller in a popover. On iPhone and iPod touch, you must present it modally."

He also provided me with the required code to do so (thanks!). I've adapted it a little to make sure current behaviour is
not altered, but with a little extra effort you can use this new popover feature.

The trick is overriding the function `window.plugins.socialsharing.iPadPopupCoordinates` by your own implementation
to tell the iPad where to show the popup exactly. It need to be a string like "100,200,300,300" (left,top,width,height).

You need to override this method after `deviceready` has fired.

You have various options, like checking the click event on a button and determine the event.clientX and event.clientY,
or use this code Carlos showed me to grab the coordinates of a static button somewhere on your page:

```js
window.plugins.socialsharing.iPadPopupCoordinates = function() {
  var rect = document.getElementById('share_button').getBoundingClientRect();
  return rect.left + "," + rect.top + "," + rect.width + "," + rect.height;
};
```

Note that since iOS 8 this popup is the only way Apple allows you to share stuff, so this plugin has been adjusted to use this plugin as standard for iOS 8 and positions
the popup at the bottom of the screen (seems like a logical default because that's where it previously was as well).
You can however override this position in the same way as explained above.

**Note**: when using the [WkWebView polyfill](https://github.com/Telerik-Verified-Plugins/WKWebView) the `iPadPopupCoordinates` overrides [doesn't work](https://github.com/Telerik-Verified-Plugins/WKWebView/issues/77) so you can call the alternative `setIPadPopupCoordinates` method to define the popup position just before you call the `share` method.

example :

```js
var targetRect = event.targetElement.getBoundingClientRect(),
    targetBounds = targetRect.left + ',' + targetRect.top + ',' + targetRect.width + ',' + targetRect.height;

window.plugins.socialsharing.setIPadPopupCoordinates(targetBounds);
window.plugins.socialsharing.share('Hello from iOS :)')
```

## 8. Whitelisting on iOS

Since iOS 9 you have to make sure to whitelist the applications you want to use for sharing. Without whitelisting "query schemes", you may get the error callback invoked when calling the `canShareVia` function (and possibly the `shareVia`). You can verify this is a permissions issue by observing the output in Xcode for something like:

> -canOpenURL: failed for URL: "whatsapp://app" - error: "This app is not allowed to query for scheme whatsapp"

You have a few options to prevent this by whitelisting the application you want to share via:

### Directly editing the .plist file
Manually edit the .plist file - either from within Xcode or using a text editor. You can see example entries above (look for `LSApplicationQueriesSchemes`). While this is simple to do, the changes may be lost when rebuilding the project or tweaking the platform (e.g. upgrading) and is less recommended.

### Use query schema plugin
There is a plugin designed specifically to address query schema whitelisting. You can find the plugin and how to use it [here](https://www.npmjs.com/package/cordova-plugin-queries-schemes). In general, after installation, you can change plugin.xml file under the plugin subfolder within the plugins directory of your project to add the required schemas. Here again though, you have to edit an additional file and should take care not to overwrite it when making changes to your project.

### Use Custom Config plugin
The Custom Config plugin ([here](https://github.com/dpa99c/cordova-custom-config)) allows you to add configuration to your platforms "native" configuration files (e.g. .plist or AndroidManifest.xml) through the project's main config.xml file.

To address query schema issue, after installaing the plugin you can edit the iOS platform section of your config.xml (in the project main folder) to include the required entries:

```xml
<?xml version='1.0' encoding='utf-8'?>
<widget id="your.app.id"
        version="0.9.1"
        xmlns="http://www.w3.org/ns/widgets"
        xmlns:cdv="http://cordova.apache.org/ns/1.0">

    <!-- a bunch of elements like name, description etc -->

    <platform name="ios">

        <!-- add this entry -->
        <config-file platform="ios" target="*-Info.plist" parent="LSApplicationQueriesSchemes">
            <array>
                <string>whatsapp</string>
                <!-- add more query scheme strings -->
            </array>
        </config-file>
    </platform>
</widget>
```

The advantage with this method is that editing is done in the config.xml file which will most often be in your source control anyway and hence, changes to it will be reserved.

## 9. NSPhotoLibraryUsageDescription on iOS

This plugin requires permissions to the users photos. Since iOS 10 it is required that you provide a description for this access.

The plugin configures a default description for you. If you do need to customise it, you can set a Cordova variable when installing:

```
$ cordova plugin add cordova-plugin-x-socialsharing --variable PHOTO_LIBRARY_USAGE_DESCRIPTION="This app uses your photo library" --variable PHOTO_LIBRARY_ADD_USAGE_DESCRIPTION="This app saves images your photo library"
```

## 10. Import Types into an Ionic Angular Project

If you do not already have a typings file definition, create one inside your `src` folder, for example`src/typings.d.ts`

Add this reference into your typings file definition:
```
/// <reference path="../node_modules/cordova-plugin-x-socialsharing/types/index.d.ts" />
```

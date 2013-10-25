# PhoneGap Social Sharing plugin for Android and iOS6+

by [Eddy Verbruggen](http://www.x-services.nl)

* These instructions are for PhoneGap 3.0.0 and up.
* For Phonegap 2.9.0 and lower, see [the readme of version 2.1](https://github.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin/blob/7e7db33179bee1b1a7573080dd9f95abd59ef0c8/README.md).

## 0. Index

1. [Description](https://github.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin#1-description)
2. [Installation](https://github.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin#2-installation)
	2. [Automatically (CLI / Plugman)](https://github.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin#automatically-cli--plugman)
	2. [Manually](https://github.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin#manually)
	2. [PhoneGap Build](https://github.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin#phonegap-build)
3. [Usage](https://github.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin#3-usage)
4. [Credits](https://github.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin#4-credits)
5. [License](https://github.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin#5-license)

## 1. Description

This plugin allows you to use the native sharing window of your mobile device.

* Works on Android, version 2.3.3 and higher (probably 2.2 as well).
* Works on iOS, version 6 and higher.
* Share text, a link, and image, or all of those. Subject is also supported, when the receiving app supports it.
* Supports sharing images from the internet, the local filesystem, or from the www folder.
* Compatible with [Cordova Plugman](https://github.com/apache/cordova-plugman).
* Officially supported by [PhoneGap Build](https://build.phonegap.com/plugins/136).

iOS 6 screenshot (options are based on what has been setup in the device settings):

![ScreenShot](https://raw.github.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin/master/screenshot.png)

## 2. Installation

### Automatically (CLI / Plugman)
SocialSharing is compatible with [Cordova Plugman](https://github.com/apache/cordova-plugman), compatible with [PhoneGap 3.0 CLI](http://docs.phonegap.com/en/3.0.0/guide_cli_index.md.html#The%20Command-line%20Interface_add_features), here's how it works with the CLI:

```
$ phonegap local plugin add https://github.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin.git
```
or
```
$ cordova plugin add https://github.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin.git
```
run this command afterwards:
```
$ cordova prepare
```
Then reference `SocialSharing.js` in `index.html`, after `cordova.js`/`phonegap.js`. Mind the path:
```html
<script type="text/javascript" src="js/plugins/SocialSharing.js"></script>
```

### Manually

1\. Add the following xml to your `config.xml` in the root directory of your `www` folder:
```xml
<!-- for iOS -->
<feature name="SocialSharing">
	<param name="ios-package" value="SocialSharing" />
</feature>
```
```xml
<!-- for Android -->
<feature name="SocialSharing">
  <param name="android-package" value="nl.xservices.plugins.SocialSharing" />
</feature>
```

For Android, images from the internet are only shareable with this permission added to `AndroidManifest.xml`:
```xml
<config-file target="AndroidManifest.xml" parent="/manifest">
  <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
</config-file>
```

2\. Grab a copy of SocialSharing.js, add it to your project and reference it in `index.html`:
```html
<script type="text/javascript" src="js/SocialSharing.js"></script>
```

3\. Download the source files for iOS and/or Android and copy them to your project.

iOS: Copy `SocialSharing.h` and `SocialSharing.h` to `platforms/ios/<ProjectName>/Plugins`

Android: Copy `SocialSharing.java` to `platforms/android/src/nl/xservices/plugins` (create the folders)

### PhoneGap Build

SocialSharing works with PhoneGap build too! Version 3.0 of this plugin is compatible with PhoneGap 3.0.0 and up.
Use an older version of this plugin if you target PhoneGap < 3.0.0.

You can implement the plugin with these simple steps.

1\. Add the following xml to your `config.xml` to always use the latest version of this plugin:
```xml
<gap:plugin name="nl.x-services.plugins.socialsharing" />
```
or to use this exact version:
```xml
<gap:plugin name="nl.x-services.plugins.socialsharing" version="3.1" />
```

2\. Reference the JavaScript code in your `index.html`:
```html
<!-- below <script src="phonegap.js"></script> -->
<script src="js/plugins/SocialSharing.js"></script>
```


## 3. Usage
You can share text, a subject (in case the user selects the email application), (any type and location of) image, and a link.
However, what exactly gets shared, depends on the application the user chooses to complete the action. A few examples:
- Mail: message, subject, image.
- Twitter: message, image, link (which is automatically shortened).
- Google+ / Hangouts: message, subject, link
- Facebook iOS: message, image, link.
- Facebook Android: when an image is passed to Facebook, the message needs to be entered by the user.
- Facebook Android: when a link is added to the message, the link is shared, the message needs to be entered by the user.

Here are some examples you can copy-paste to test the various combinations:
```html
  <button onclick="window.plugins.socialsharing.share('Message only')">message only</button>
  <button onclick="window.plugins.socialsharing.share('Message and subject', 'The subject')">message and subject</button>
  <button onclick="window.plugins.socialsharing.share(null, null, null, 'http://www.x-services.nl')">link only</button>
  <button onclick="window.plugins.socialsharing.share('Message and link', null, null, 'http://www.x-services.nl')">message and link</button>
  <button onclick="window.plugins.socialsharing.share(null, null, 'https://www.google.nl/images/srpr/logo4w.png', null)">image only</button>
  <button onclick="window.plugins.socialsharing.share('Message and image', null, 'https://www.google.nl/images/srpr/logo4w.png', null)">message and image</button>
  <button onclick="window.plugins.socialsharing.share('Message, image and link', null, 'https://www.google.nl/images/srpr/logo4w.png', 'http://www.x-services.nl')">message, image and link</button>
  <button onclick="window.plugins.socialsharing.share('Message, subject, image and link', 'The subject', 'https://www.google.nl/images/srpr/logo4w.png', 'http://www.x-services.nl')">message, subject, image and link</button>
```

Want to share images from a local folder (like an image you just selected from the CameraRoll)?
```javascript
// note: instead of available(), you could also check the useragent (android or ios6+)
window.plugins.socialsharing.available(function(isAvailable) {
  if (isAvailable) {
    // use a local image from inside the www folder:
    window.plugins.socialsharing.share(null, null, 'www/image.gif', null); // succes/error callback params may be added as 5th and 6th param
    // .. or a local image from anywhere else (if permitted):
    // local-iOS:
    window.plugins.socialsharing.share(null, null, '/Users/username/Library/Application Support/iPhone/6.1/Applications/25A1E7CF-079F-438D-823B-55C6F8CD2DC0/Documents/.nl.x-services.appname/pics/img.jpg');
    // local-iOS-alt:
    window.plugins.socialsharing.share(null, null, 'file:///Users/username/Library/Application Support/iPhone/6.1/Applications/25A1E7CF-079F-438D-823B-55C6F8CD2DC0/Documents/.nl.x-services.appname/pics/img.jpg');
    // local-Android:
    window.plugins.socialsharing.share(null, null, 'file:///storage/emulated/0/nl.xservices.testapp/5359/Photos/16832/Thumb.jpg');
    // .. or an image from the internet:
    window.plugins.socialsharing.share(null, null, 'http://domain.com/image.jpg');
  }
});
```

#### iOS quirk (with camera plugin)
When using this plugin in the callback of the Phonegap camera plugin, wrap the call to `share()` in a `setTimeout()`.
The share widget has the same limitation as the alert dialogue [mentioned in the Phonegap documentation](http://docs.phonegap.com/en/2.9.0/cordova_camera_camera.md.html#camera.getPicture_ios_quirks).

#### Excluding some options from the widget
If you want to exclude (for example) the assign-to-contact and copy-to-pasteboard options, add these lines
right before the last line of the share() method in SocialSharing.m (see the commented lines in that file):
```
NSArray * excludeActivities = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard];
activityVC.excludedActivityTypes = excludeActivities;
```
I'll probably make this configurable via Javascript one day.
And thanks for the tip, Simon Robichaud!

## 4. CREDITS ##

This plugin was enhanced for Plugman / PhoneGap Build by [Eddy Verbruggen](http://www.x-services.nl).
The Android code was entirely created by the author.
The iOS code was inspired by [Cameron Lerch](https://github.com/bfcam/phonegap-ios-social-plugin).
I also included a nice enhancement posted [here](https://github.com/bfcam/phonegap-ios-social-plugin/issues/3#issuecomment-21353674) to allow sharing files from the internet.


## 5. License

[The MIT License (MIT)](http://www.opensource.org/licenses/mit-license.html)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/EddyVerbruggen/socialsharing-phonegap-plugin/trend.png)](https://bitdeli.com/free "Bitdeli Badge")


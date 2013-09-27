# PhoneGap Social Sharing plugin for Android and iOS6+

by [Eddy Verbruggen](http://www.x-services.nl)

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

* Works on Android, version 2.3.3 and higher (possibly even lower)
* Works on iOS, version 6 and higher
* Share text or an image (or both). Subject is also supported, when the receiving app supports it.
* Supports sharing images from the internet, the local filesystem, or from the www folder
* Compatible with [Cordova Plugman](https://github.com/apache/cordova-plugman) and ready for PhoneGap 3.0
* Officially supported by [PhoneGap Build](https://build.phonegap.com/plugins/95)

iOS screenshot (options are based on what has been setup in the device settings):

![ScreenShot](https://raw.github.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin/master/screenshot.png)

## 2. Installation

### Automatically (CLI / Plugman)
SocialSharing is compatible with [Cordova Plugman](https://github.com/apache/cordova-plugman) and ready for the [PhoneGap 3.0 CLI](http://docs.phonegap.com/en/3.0.0/guide_cli_index.md.html#The%20Command-line%20Interface_add_features), here's how it works with the CLI:

```
$ phonegap local plugin add https://github.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin.git
```
or
```
$ cordova plugin add https://github.com/EddyVerbruggen/SocialSharing-PhoneGap-Plugin.git
```
don't forget to run this command afterwards:
```
$ cordova build
```
Then reference `SocialSharing.js` in `index.html`, after `cordova.js`:
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
<!-- for Android as plugin (deprecated) -->
<plugin name="SocialSharing" value="nl.xservices.plugins.SocialSharing"/>
```

```xml
<!-- for Android as feature -->
<feature name="SocialSharing">
  <param name="android-package" value="nl.xservices.plugins.SocialSharing" />
</feature>
```

Also for Android, images from the internet are only shareable with this permission added to `AndroidManifest.xml`:
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

SocialSharing works with PhoneGap build too. You can implement the plugin with these simple steps.

1\. Add the following xml to your `config.xml` to always use the latest version of this plugin:
```xml
<gap:plugin name="nl.x-services.plugins.socialsharing" />
```
or to use this exact version:
```xml
<gap:plugin name="nl.x-services.plugins.socialsharing" version="2.0" />
```

2\. Reference the JavaScript code in your `index.html`:
```html
<!-- below <script src="phonegap.js"></script> -->
<script src="js/plugins/SocialSharing.js"></script>
```


## 3. Usage
You can share text (including a link), a subject and (any type of) image. However, what exactly gets shared,
depends on the application the user chooses to complete the action. A few examples:
- Mail: message, subject, image.
- Twitter: message, image (any link in the message will be nicely shortened).
- Google+ / Hangouts: message, subject.
- Facebook iOS: message, image.
- Facebook Android: when an image is passed to Facebook, the message needs to be entered by the user.
- Facebook Android: when a link is added to the message, the link is shared, the message needs to be entered by the user.

```javascript
// note: instead of available(), you could also check the useragent (android or ios6+)
window.plugins.socialsharing.available(function(isAvailable) {
  if (isAvailable) {
    // use a local image from inside the www folder:
    window.plugins.socialsharing.share('My text with a link: http://domain.com', 'My subject', 'www/image.gif'); // succes/error callback params may be added as 4th and 5th param
    // .. or a local image from anywhere else (if permitted):
    // local-iOS:
    window.plugins.socialsharing.share('My text with a link: http://domain.com', 'My subject', '/Users/username/Library/Application Support/iPhone/6.1/Applications/25A1E7CF-079F-438D-823B-55C6F8CD2DC0/Documents/.nl.x-services.appname/pics/img.jpg');
    // local-Android:
    window.plugins.socialsharing.share('My text with a link: http://domain.com', 'My subject', 'file:///storage/emulated/0/nl.xservices.testapp/5359/Photos/16832/Thumb.jpg');
    // .. or an image from the internet:
    window.plugins.socialsharing.share('My text with a link: http://domain.com', 'My subject', 'http://domain.com/image.jpg');
    // .. or only text:
    window.plugins.socialsharing.share('My text');
    // .. (or like this):
    window.plugins.socialsharing.share('My text', null, null);
  }
});
```


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


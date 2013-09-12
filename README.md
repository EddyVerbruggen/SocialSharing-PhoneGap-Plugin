# PhoneGap Social Sharing plugin for iOS (and Android soon)

by [Eddy Verbruggen](http://www.x-services.nl)

1. [Description](https://github.com/ohh2ahh/AppAvailability#1-description)
2. [Installation](https://github.com/ohh2ahh/AppAvailability#2-installation)
	2. [Automatically (CLI / Plugman)](https://github.com/ohh2ahh/AppAvailability#automatically-cli--plugman)
	2. [Manually](https://github.com/ohh2ahh/AppAvailability#manually)
	2. [PhoneGap Build](https://github.com/ohh2ahh/AppAvailability#phonegap-build)
3. [Usage](https://github.com/ohh2ahh/AppAvailability#3-usage)
	3. [iOS](https://github.com/ohh2ahh/AppAvailability#ios)
	3. [Android](https://github.com/ohh2ahh/AppAvailability#android)
4. [License](https://github.com/ohh2ahh/AppAvailability#5-license)

## 1. Description

This plugin allows you to use the native sharing window of your mobile device.

* iOS6 and up (and Android soon)
* Share text, an URL, or an image (or all at once
* Supports sharing images from the internet, or from the local www folder
* Compatible with [Cordova Plugman](https://github.com/apache/cordova-plugman) and ready for PhoneGap 3.0
* Will hopefully work soon with PhoneGap Build ([more information](https://build.phonegap.com/plugins))

## 2. Installation

### Automatically (CLI / Plugman)
SocialSharing is compatible with [Cordova Plugman](https://github.com/apache/cordova-plugman) and ready for the [PhoneGap 3.0 CLI](http://docs.phonegap.com/en/3.0.0/guide_cli_index.md.html#The%20Command-line%20Interface_add_features), here's how it works with the CLI:

```
$ phonegap local plugin add https://github.com/eddyverbruggen/SocialSharing.git
```

### Manually

1\. Add the following xml to your `config.xml` in the root directory of your `www` folder:
```xml
<!-- for iOS -->
<feature name="AppAvailability">
	<param name="ios-package" value="AppAvailability" />
</feature>
```

2\. Grab a copy of SocialSharing.js, add it to your project and reference it in `index.html`:
```html
<script type="text/javascript" src="js/SocialSharing.js"></script>
```

3\. Download the source files for iOS and/or Android and copy them to your project.

iOS: Copy `SocialSharing.h` and `SocialSharing.h` to `platforms/ios/<ProjectName>/Plugins`


### PhoneGap Build

SocialSharing works with PhoneGap build too. You can implement the plugin with these simple steps.

1\. Add the following xml to your `config.xml` to always use the latest version of this plugin:
```xml
<gap:plugin name="nl.x-services.plugins.socialsharing" />
```
or to use this exact version:
```xml
<gap:plugin name="nl.x-services.plugins.socialsharing" version="0.1.0" />
```

2\. Reference the JavaScript code in your `index.html`:
```html
<!-- below <script src="phonegap.js"></script> -->
<script src="js/plugins/SocialSharing.js"></script>
```


## 3. Usage

### iOS

```javascript
window.plugins.social.available(function(isAvailable) {
  if (isAvailable) {
    // use a local image, must be inside the www folder:
    window.plugins.social.share('Some text', 'http://domain.com', 'www/image.gif');
    // .. or an image from the internet:
    window.plugins.socialsharing.share('Some text', 'http://domain.com', 'http://domain.com/image.jpg');
    // .. or only text:
    window.plugins.socialsharing.share('Some text', '', '');
  }
});
```


## 4. License

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

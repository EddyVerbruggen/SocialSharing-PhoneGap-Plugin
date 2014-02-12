function SocialSharing() {
}

SocialSharing.prototype.available = function (callback) {
  cordova.exec(function (avail) {
    callback(avail ? true : false);
  }, null, "SocialSharing", "available", []);
};

SocialSharing.prototype.share = function (message, subject, file, url, successCallback, errorCallback) {
  cordova.exec(successCallback, errorCallback, "SocialSharing", "share", [message, subject, file, url]);
};

SocialSharing.prototype.shareViaTwitter = function (message, image, url, successCallback, errorCallback) {
  cordova.exec(successCallback, errorCallback, "SocialSharing", "shareViaTwitter", [message, null, image, url]);
};

SocialSharing.prototype.shareViaFacebook = function (message, image, url, successCallback, errorCallback) {
  cordova.exec(successCallback, errorCallback, "SocialSharing", "shareViaFacebook", [message, null, image, url]);
};

SocialSharing.prototype.shareViaWhatsApp = function (message, image, url, successCallback, errorCallback) {
  cordova.exec(successCallback, errorCallback, "SocialSharing", "shareViaWhatsApp", [message, null, image, url]);
};

SocialSharing.prototype.shareViaSMS = function (message, phonenumbers, successCallback, errorCallback) {
  cordova.exec(successCallback, errorCallback, "SocialSharing", "shareViaSMS", [message, phonenumbers]);
};

SocialSharing.prototype.canShareVia = function (via, message, subject, image, url, successCallback, errorCallback) {
  cordova.exec(successCallback, errorCallback, "SocialSharing", "canShareVia", [message, subject, image, url, via]);
};

SocialSharing.prototype.shareVia = function (via, message, subject, image, url, successCallback, errorCallback) {
  cordova.exec(successCallback, errorCallback, "SocialSharing", "shareVia", [message, subject, image, url, via]);
};

SocialSharing.install = function () {
  if (!window.plugins) {
    window.plugins = {};
  }

  window.plugins.socialsharing = new SocialSharing();
  return window.plugins.socialsharing;
};

cordova.addConstructor(SocialSharing.install);
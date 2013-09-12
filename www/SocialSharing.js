function SocialSharing() {
}

SocialSharing.prototype.available = function (callback) {
  cordova.exec(function (avail) {
    callback(avail ? true : false);
  }, null, "SocialSharing", "available", []);
};

SocialSharing.prototype.share = function (message, url, image) {
  cordova.exec(null, null, "SocialSharing", "share", [message, image, url]);
};

SocialSharing.install = function () {
  if (!window.plugins) {
    window.plugins = {};
  }

  window.plugins.socialsharing = new SocialSharing();
  return window.plugins.socialsharing;
};

cordova.addConstructor(SocialSharing.install);
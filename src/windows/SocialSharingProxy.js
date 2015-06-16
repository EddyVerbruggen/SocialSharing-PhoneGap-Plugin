var cordova = require('cordova');

module.exports = {
    share: function (win, fail, args) {
        //Text Message
        var message = args[0];
        //Title 
        var subject = args[1];
        //File(s) Path
        var fileOrFileArray = args[2];
        //Web link
        var url = args[3];

        var doShare = function (e) {
            e.request.data.properties.title = subject?subject: "Sharing";
            if (message) e.request.data.setText(message);
            if (url) e.request.data.setWebLink(new Windows.Foundation.Uri(url));
            if (fileOrFileArray.length > 0) {
                var deferral = e.request.getDeferral();
                var storageItems = [];
                var filesCount = fileOrFileArray.length;
                for (var i = 0; i < fileOrFileArray.length; i++) {
                    Windows.Storage.StorageFile.getFileFromPathAsync(fileOrFileArray[i]).done(
                        function (file) {
                            storageItems.push(file);
                            if (!--filesCount) {
                                e.request.data.setStorageItems(storageItems);
                                deferral.complete();
                            }
                        },
                        function() {
                            if (!--filesCount) {
                                e.request.data.setStorageItems(storageItems);
                                deferral.complete();
                            }
                       }
                    );
                }
            }
        }


        var dataTransferManager = Windows.ApplicationModel.DataTransfer.DataTransferManager.getForCurrentView();

        dataTransferManager.addEventListener("datarequested", doShare);

        try {
            Windows.ApplicationModel.DataTransfer.DataTransferManager.showShareUI();
            win(true);
        } catch (err) {
            fail(err);
        }
    },

    canShareViaEmail: function (win, fail, args) {
        win(true);
    },

    shareViaEmail: function (win, fail, args) {
        //Text Message
        var message = args[0];
        //Title 
        var subject = args[1];
        //File(s) Path
        var fileOrFileArray = args[5];

        var doShare = function (e) {
            e.request.data.properties.title = subject ? subject : "Sharing";
            if (message) {
                var htmlFormat = Windows.ApplicationModel.DataTransfer.HtmlFormatHelper.createHtmlFormat(message);
                e.request.data.setHtmlFormat(htmlFormat);
            }

            if (fileOrFileArray.length > 0) {
                var deferral = e.request.getDeferral();
                var storageItems = [];
                var filesCount = fileOrFileArray.length;
                for (var i = 0; i < fileOrFileArray.length; i++) {
                    Windows.Storage.StorageFile.getFileFromPathAsync(fileOrFileArray[i]).done(
                        function (index, file) {
                            var path = fileOrFileArray[index];
                            var streamRef = Windows.Storage.Streams.RandomAccessStreamReference.createFromFile(file);
                            e.request.data.resourceMap[path] = streamRef;
                            storageItems.push(file);
                            if (!--filesCount) {
                                e.request.data.setStorageItems(storageItems);
                                deferral.complete();
                            }
                        }.bind(this, i),
                        function () {
                            if (!--filesCount) {
                                e.request.data.setStorageItems(storageItems);
                                deferral.complete();
                            }
                        }
                    );
                }
            }
        }

        var dataTransferManager = Windows.ApplicationModel.DataTransfer.DataTransferManager.getForCurrentView();

        dataTransferManager.addEventListener("datarequested", doShare);

        try {
            Windows.ApplicationModel.DataTransfer.DataTransferManager.showShareUI();
            win(true);
        } catch (err) {
            fail(err);
        }
    }
};

require("cordova/exec/proxy").add("SocialSharing", module.exports);
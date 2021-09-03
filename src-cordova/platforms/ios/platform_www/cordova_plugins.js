cordova.define('cordova/plugin_list', function(require, exports, module) {
  module.exports = [
    {
      "id": "cordova-plugin-apple-pay-google-pay.ApplePayGooglePay",
      "file": "plugins/cordova-plugin-apple-pay-google-pay/www/ApplePayGooglePay.js",
      "pluginId": "cordova-plugin-apple-pay-google-pay",
      "clobbers": [
        "cordova.plugins.ApplePayGooglePay"
      ]
    }
  ];
  module.exports.metadata = {
    "cordova-plugin-whitelist": "1.3.5",
    "cordova-plugin-apple-pay-google-pay": "1.0.0"
  };
});
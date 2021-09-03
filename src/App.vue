<template>
  <div id="app">
   <button @click="pay">Кнопка</button>
  </div>
</template>

<script>
import http from "./http";
export default {
  name: 'App',
  methods:{
    pay(){
      let request = {
        merchantId: 'merchant.ru.yobidoyobi', // obtain it from https://developer.apple.com/account/resources/identifiers/list/merchant
        purpose: `Payment for your order #1`,
        amount: 5,
        countryCode: "RU",
        currencyCode: "RUB"
      }
      // eslint-disable-next-line
      cordova.plugins.ApplePayGooglePay.makePaymentRequest(request, r => {
            // in success callback, raw response as encoded JSON is returned. Pass it to your payment processor as is.
            let responseString = r
            http.post('/api/debug/report', responseString)
                // eslint-disable-next-line no-unused-vars
                .then(r => {
                  alert('Данные отправлены на сервер!')
                })
                // eslint-disable-next-line no-unused-vars
                .catch((e) => {
                 alert('Сервер не принял данные!')
                });
            alert(r);
          },
          // eslint-disable-next-line no-unused-vars
          r => {
            // in error callback, error message is returned.
            // it will be "Payment cancelled" if used pressed Cancel button.
          }
      )
    }
  }
}
</script>

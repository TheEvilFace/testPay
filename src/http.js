"use strict";

import axios from 'axios';
import Vue from 'vue';

const http = axios.create({
    baseURL: 'https://mobileapp.yobidoyobi.ru/v2',
    credentials: false
});

Vue.prototype.$http = http;

export default http;
import { isEmpty } from "./validator";

const axios = require('axios');
const defaultBaseURL = "http://localhost:3000/";

export const get_base_url = () => {
    return isEmpty(localStorage.BaseURL) ? defaultBaseURL : localStorage.BaseURL;
}

export const set_up_axios = () => {
    axios.interceptors.request.use(function (config) {
        console.log("REQUESTING URL");
        return config;
    }, function (error) {
        console.log("ERROR IN REQUEST");
        return Promise.reject(error);
    });

    axios.interceptors.response.use(function (response) {
        console.log("RESPONSE RECEIVED");
        return response;
    }, function (error) {
        console.log("ERROR IN RESPONSE");
        return Promise.reject(error);
    });
}
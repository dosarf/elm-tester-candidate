'use strict';

require('ace-css/css/ace.min.css');

import img from './assets/free-logo.png'
require('./index.html');
var elm = require('./Main.elm');

var app = elm.Elm.Main.init({
  node: document.getElementById('main')
});

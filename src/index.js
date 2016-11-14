'use strict';

require('./index.html');

require('style!css!font-awesome/css/font-awesome.css');
require('./styles.sass');

global.jQuery = require('jquery/dist/jquery.slim.js');
global.Tether = require('tether/dist/js/tether.js');
require('bootstrap/dist/js/bootstrap.js');

var Elm = require('./Main.elm');
var node = document.getElementById('main');

var app = Elm.Main.embed(node);

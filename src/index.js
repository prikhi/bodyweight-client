'use strict';

require('./index.html');

var Elm = require('./Main.elm');
var node = document.getElementById('main');

var app = Elm.Main.embed(node);

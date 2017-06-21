'use strict';

require('./index.html');

require('style-loader!css-loader!font-awesome/css/font-awesome.css');
require('./styles.sass');

global.jQuery = require('jquery/dist/jquery.slim.js');
global.Tether = require('tether/dist/js/tether.js');
require('bootstrap/dist/js/bootstrap.js');

var Elm = require('./Main.elm');
var node = document.getElementById('main');
var token = localStorage.getItem('authToken');
var userId = localStorage.getItem('authUserId');
if (userId !== null) { userId = parseInt(userId); }

var app = Elm.Main.embed(node, {
  authToken: token,
  authUserId: userId,
});


/* Save the Auth Token to Local Storage so we can re-authenticate on reload */
app.ports.storeAuthDetails.subscribe(function(userDetails) {
  var [token, userId] = userDetails;
  localStorage.setItem('authToken', token);
  localStorage.setItem('authUserId', userId);
});

/* Remove the Auth Token from Local Storage */
app.ports.removeAuthDetails.subscribe(function() {
  localStorage.removeItem('authToken');
  localStorage.removeItem('authUserId');
});

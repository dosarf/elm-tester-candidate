'use strict';

require('ace-css/css/ace.css');
require('font-awesome/css/font-awesome.css');

// Require index.htlm so it gets copied to distribution
require('./index.html');

var Elm = require('./Main.elm');
var mountNode = document.getElementById('main');

// embed() can take an optional 2nd arg
// This would be an object describing the data we need
// to start the program with, i.e. a user ID or some token
var app = Elm.Main.embed(mountNode);

app.ports.confirmIssueDiscard.subscribe(function(issueId){
  if (confirm('You are about to discard issue #' + issueId)) {
    app.ports.issueDiscardConfirmation.send([ true, issueId ]);
  } else {
    app.ports.issueDiscardConfirmation.send([ false, issueId ]);
  }
});

app.ports.alertBackendError.subscribe(function(message){
  alert(message);
});

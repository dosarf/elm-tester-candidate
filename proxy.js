//
// For our purposes, json-server serving from db.json is perfect.
// Instead of figuring out how to serve the Elm app and the json server
// from the same Node JS process, we just add this here proxy -> browser
// does not need to use different port for JSON API.
//

var http = require('http'),
    httpProxy = require('http-proxy');

//
// Create a proxy server with custom application logic
//
var proxy = httpProxy.createProxyServer({});

//
// Listen for the `error` event on `proxy`.
proxy.on('error', function (err, req, res) {
  res.writeHead(500, {
    'Content-Type': 'text/plain'
  });

  res.end('Something went wrong. And we are reporting a custom error message.');
});

var jsonApiRequestRegexp = new RegExp("/issue(Config|s(/.+)?)$");
var elmTarget = "http://127.0.0.1:3000";
var jsonServerTarget = "http://127.0.0.1:4000";

//
// Create your custom server and just call `proxy.web()` to proxy
// a web request to the target passed in the options
// also you can use `proxy.ws()` to proxy a websockets request
//
var server = http.createServer(function(req, res) {
  var target = jsonApiRequestRegexp.test(req.url) ? jsonServerTarget : elmTarget;

  proxy.web(req, res, { target: target });
});

var facadePort = 7096;
console.log("listening on port " + facadePort);
server.listen(facadePort);

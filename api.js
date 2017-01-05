var jsonServer = require('json-server');
var server = jsonServer.create();
var router = jsonServer.router('db.json');
var middlewares = jsonServer.defaults();

server.use(middlewares);
server.use(router);
var port = 4000;
server.listen(port, function () {
  console.log('JSON Server is listening at ' + port)
});

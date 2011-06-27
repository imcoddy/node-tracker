(function() {
  var app, express, util;
  express = require('express');
  util = require('util');
  app = module.exports = express.createServer();
  app.configure(function() {
    app.set('views', __dirname + '/../views');
    app.set('view engine', 'jade');
    app.use(express.bodyParser());
    app.use(express.methodOverride());
    app.use(app.router);
    return app.use(express.static(__dirname + '/../public'));
  });
  app.configure('development', function() {
    return app.use(express.errorHandler({
      dumpExceptions: true,
      showStack: true
    }));
  });
  app.configure('production', function() {
    return app.use(express.errorHandler());
  });
  app.get('/', function(req, res) {
    return res.render('index', {
      title: 'Coffee in Express'
    });
  });
  app.listen(3000);
  console.log("Express server listening on port %d", app.address().port);
}).call(this);
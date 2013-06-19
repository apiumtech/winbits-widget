var fs = require('fs');
var http = require('http');
var url = require('url') ;

http.createServer(function (req, res) {
  var queryObject = url.parse(req.url,true).query;
  var callback = queryObject.callback;
  var widget = queryObject.widget;

  var widgetFile = 'widgets/' + widget + '.html';
  fs.readFile(widgetFile, 'utf8', function(error, data) {
    res.writeHead(200, {'Content-Type': 'text/javascript'});
    res.end(callback + '({"html":"' + data + '"});');
  });
}).listen(1337, '127.0.0.1');
console.log('Server running at http://127.0.0.1:1337/');
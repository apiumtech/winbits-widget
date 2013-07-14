(function(){
var JavaScript = {
  load: function(src, callback) {
    var script = document.createElement('script'),
        loaded;
    script.setAttribute('src', src);
    if (callback) {
      script.onreadystatechange = script.onload = function() {
        if (!loaded) {
          callback();
        }
        loaded = true;
      };
    }
    document.getElementsByTagName('head')[0].appendChild(script);
  }
};
var head= document.getElementsByTagName('head')[0];
var css= document.createElement('link');
css.setAttribute("rel", "stylesheet");
css.setAttribute("type", "text/css");
css.setAttribute("href", "http://widgets.winbits.com/qa/stylesheets/app.css");
head.appendChild(css);

JavaScript.load('http://widgets.winbits.com/qa/javascripts/vendor.js', function() {
});

JavaScript.load('http://widgets.winbits.com/qa/javascripts/app.js', function() {
  require('initialize');
});



})();


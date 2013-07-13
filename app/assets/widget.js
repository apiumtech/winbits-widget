(function(){
var head= document.getElementsByTagName('head')[0];


var css= document.createElement('link');
 css.setAttribute("rel", "stylesheet");
 css.setAttribute("type", "text/css");
 css.setAttribute("href", "http://widgets.winbits.com/qa/stylesheets/app.css");
 head.appendChild(css);

var vendor= document.createElement('script');
 vendor.type= 'text/javascript';
 vendor.src= 'http://widgets.winbits.com/qa/javascripts/vendor.js';
 head.appendChild(vendor);

var app= document.createElement('script');
 app.type= 'text/javascript';
 app.src= 'http://widgets.winbits.com/qa/javascripts/app.js';
 head.appendChild(app);

 app.onreadystatechange= function () {
 if (this.readyState == 'complete'){
  console.log("weeeeee");
        require('initialize')
   }
 }

})();


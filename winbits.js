var Winbits = {};

(function() {
  // Localize jQuery variable
  Winbits.jQuery;

  /******** Load jQuery if not present *********/
  if (window.jQuery === undefined || window.jQuery.fn.jquery !== '1.8.3') {
    var scriptTag = document.createElement('script');
    scriptTag.setAttribute("type","text/javascript");
    scriptTag.setAttribute("src",
        "http://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js");
    if (scriptTag.readyState) {
      scriptTag.onreadystatechange = function () { // For old versions of IE
        if (this.readyState == 'complete' || this.readyState == 'loaded') {
          scriptLoadHandler();
        }
      };
    } else {
      scriptTag.onload = scriptLoadHandler;
    }
    // Try to find the head, otherwise default to the documentElement
    (document.getElementsByTagName("head")[0] || document.documentElement).appendChild(scriptTag);
  } else {
    // The jQuery version on the window is the one we want to use
    Winbits.jQuery = window.jQuery;
    main();
  }

  /******** Called once jQuery has loaded ******/
  function scriptLoadHandler() {
    // Restore $ and window.jQuery to their previous values and store the
    // new jQuery in our local jQuery variable
    Winbits.jQuery = window.jQuery.noConflict(true);
    // Call our main function
    main();
  }

  Winbits.winbitsReady = function () {
    // Check for presence of required DOM elements or other JS your widget depends on
    var $widgetContainer = Winbits.jQuery('#winbits-widget');
    if ($widgetContainer.length > 0) {
      window.clearInterval(Winbits._readyInterval);
      var $ = Winbits.jQuery;
      /******* Load CSS *******/
      var css_link = $("<link>", {
        rel: "stylesheet",
        type: "text/css",
        href: "style.css"
      });
      css_link.appendTo('head');

      /******* Load HTML *******/
      /*var jsonpUrl = "http://al.smeuh.org/cgi-bin/webwidget_tutorial.py?callback=?";
      $.getJSON(jsonpUrl, function(data) {
        $('#example-widget-container').html("This data comes from another server: " + data.html);
      });*/
    }
  };

  /******** Our main function ********/
  function main() {
    Winbits._readyInterval = window.setInterval(Winbits.winbitsReady, 500);
  }

})(); // We call our anonymous function immediately
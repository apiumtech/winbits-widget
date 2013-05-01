var Winbits = { extraScriptLoaded: false };
Winbits.config = {
  apiUrl: 'http://api.winbits.com/v1'
};

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
    jQuery = Winbits.jQuery;
    // Call our main function
    main();
  }

  Winbits.winbitsReady = function () {
    // Check for presence of required DOM elements or other JS your widget depends on
    var $widgetContainer = Winbits.jQuery('#winbits-widget');
    if (Winbits.extraScriptLoaded && $widgetContainer.length > 0) {
      window.clearInterval(Winbits._readyInterval);
      var $ = Winbits.jQuery;
      /******* Load HTML *******/
      $('#winbits-widget').load('http://api.winbits.com/widgets/widgets/winbits.html', function() {
        jcf.customForms.replaceAll();
        initTouchNav();
        initCarousel();
        initCycleCarousel();
        initDropDown();
        initOpenClose();
        initLightbox();
        initPopups();
        initInputs();
        initAddClasses();
        initValidation();
        initCounter();
        initSlider();
        initRadio();
        Winbits.init();
      });
    }
  };

  /******** Our main function ********/
  function main() {
    createExtraScriptTag();
    var $head = Winbits.jQuery('head');
    $head.append('<link rel="stylesheet" type="text/css" media="all" href="http://api.winbits.com/widgets/css/fancybox.css"/>');
    $head.append('<link rel="stylesheet" type="text/css" media="all" href="http://api.winbits.com/widgets/css/all.css"/>');
    $head.append('<!--[if lt IE 9]><link rel="stylesheet" type="text/css" href="http://api.winbits.com/widgets/css/ie.css" /><![endif]-->');
    Winbits._readyInterval = window.setInterval(function() {
      Winbits.winbitsReady();
    }, 50);
  }

  function createExtraScriptTag() {
    var scriptTag = document.createElement('script');
    scriptTag.setAttribute("type","text/javascript");
    scriptTag.setAttribute("src", "http://api.winbits.com/widgets/js/jquery.main.js");
    if (scriptTag.readyState) {
      scriptTag.onreadystatechange = function () { // For old versions of IE
        if (this.readyState == 'complete' || this.readyState == 'loaded') {
          Winbits.extraScriptLoaded = true;
        }
      };
    } else {
      scriptTag.onload = function() { Winbits.extraScriptLoaded = true; };
    }
    // Try to find the head, otherwise default to the documentElement
    var headTag = (document.getElementsByTagName("head")[0] || document.documentElement)
    headTag.appendChild(scriptTag);
    var jqueryFormPluginTag = document.createElement('script');
    jqueryFormPluginTag.setAttribute("type","text/javascript");
    jqueryFormPluginTag.setAttribute("src", "http://api.winbits.com/widgets/js/jquery.form.js");
    // Try to find the head, otherwise default to the documentElement
    headTag.appendChild(jqueryFormPluginTag);
  }

})(); // We call our anonymous function immediately

Winbits.init = function() {
  $('#winbits-register-form').ajaxForm(

  );
}
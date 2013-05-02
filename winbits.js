var console = window.console || {};
console.log = console.log || function() {};

var Winbits = Winbits || {};
Winbits.extraScriptLoaded = false;
Winbits.config = Winbits.config || {
  apiUrl: 'http://api.winbits.com/v1',
  widgetsUrl: 'http://api.winbits.com/widgets'
};

Winbits.$ = function(element) {
  return element instanceof Winbits.jQuery ? element : Winbits.jQuery(element);
};

Winbits.setCookie = function setCookie(c_name,value,exdays) {
  exdays = exdays || 7;
  var exdate = new Date();
  exdate.setDate(exdate.getDate() + exdays);
  var c_value = escape(value) + ((exdays==null) ? "" : "; expires=" + exdate.toUTCString());
  document.cookie=c_name + "=" + c_value;
};

Winbits.getCookie = function getCookie(c_name) {
  var c_value = document.cookie;
  var c_start = c_value.indexOf(" " + c_name + "=");
  if (c_start == -1) {
    c_start = c_value.indexOf(c_name + "=");
  }
  if (c_start == -1) {
    c_value = null;
  }
  else {
    c_start = c_value.indexOf("=", c_start) + 1;
    var c_end = c_value.indexOf(";", c_start);
    if (c_end == -1) {
      c_end = c_value.length;
    }
    c_value = unescape(c_value.substring(c_start,c_end));
  }
  return c_value;
}

Winbits.init = function() {
  var $ = Winbits.jQuery;
  Winbits.requestTokens($);
  Winbits.initWidgets($);
};

Winbits.requestTokens = function($) {
  $.ajax(Winbits.config.apiUrl + '/affiliation/tokens.json', {
    dataType: 'json',
    context: $,
    success: function(data) {
      console.log('tokens.json Success!');
      console.log(['data', data]);
      Winbits.segregateTokens(this, data.response);
      Winbits.expressLogin(this);
    },
    error: function(xhr, textStatus, errorThrown) {
      console.log('tokens.json Error!');
      var error = JSON.parse(xhr.responseText);
      alert(error.meta.message);
    }
  });
};

Winbits.segregateTokens = function($, tokensDef) {
  var guestTokenDef = tokensDef.guestToken;
  Winbits.setCookie(guestTokenDef.cookieName, guestTokenDef.value || '', guestTokenDef.expireDays);
  var apiTokenDef = tokensDef.apiToken;
  Winbits.setCookie(apiTokenDef.cookieName, apiTokenDef.value || '', apiTokenDef.expireDays);
  Winbits.tokensDef = tokensDef;
};

Winbits.expressLogin = function($) {
  var apiToken = Winbits.getCookie(Winbits.tokensDef.apiToken.cookieName);
  if (apiToken) {
    $.ajax(Winbits.config.apiUrl + '/affiliation/express-login.json', {
      type: 'POST',
      contentType: 'application/json',
      dataType: 'json',
      data: JSON.stringify({ apiToken: apiToken }),
      headers: { 'Accept-Language': 'es' },
      xhrFields: { withCredentials: true },
      context: $,
      success: function(data) {
        console.log('express-login.json Success!');
        console.log(['data', data]);
      },
      error: function(xhr, textStatus, errorThrown) {
        console.log('express-login.json Error!');
        var error = JSON.parse(xhr.responseText);
        alert(error.meta.message);
      }
    });
  } else {
    console.log('Unable to express-login without API token');
  }
};

Winbits.initWidgets = function($) {
  var $ = Winbits.jQuery;
  $('#winbits-register-form').submit(function(e) {
    e.preventDefault();
    var $form = $(this);
    var formData = { verticalId: 1 };
    $.each($form.serializeArray(), function(i, f) {
      formData[f.name] = f.value;
    });
    $.ajax(Winbits.config.apiUrl + '/affiliation/register.json', {
      type: 'POST',
      contentType: 'application/json',
      dataType: 'json',
      data: JSON.stringify(formData),
      context: $form,
      beforeSend: function() {
        return Winbits.Forms.validateForm(this);
      },
      headers: { 'Accept-Language': 'es' },
      success: function(data) {
        console.log('Request Success!');
        console.log(['data', data]);
        if (data.response.active) {
          // Transition to new state;
          alert('Must show register message');
        }
      },
      error: function(xhr, textStatus, errorThrown) {
        console.log('Request Error!');
        var error = JSON.parse(xhr.responseText);
        alert(error.meta.message);
      },
      complete: function() {
        console.log('Request Completed!');
      }
    });
  });
};

Winbits.Validations = Winbits.Validations || {};
Winbits.Validations.emailRegEx = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
Winbits.Validations.validateRequiredField = function(field) {
  var $ = Winbits.jQuery;
  var $field = Winbits.$(field);
  var fieldValue = $field.val() || '';
  return fieldValue.length > 0;
};
Winbits.Validations.validateEmailField = function(field) {
  var $ = Winbits.jQuery;
  var $field = Winbits.$(field);
  var fieldValue = $field.val() || '';
  return Winbits.Validations.emailRegEx.test(fieldValue);
};
Winbits.Validations.validateConfirmField = function(field) {
  var $ = Winbits.jQuery;
  var $field = Winbits.$(field);
  var targetField;
  $.each($field.attr('class').split(/\s+/), function(i, className) {
    if (className.indexOf('confirm-') === 0) {
      targetField = className.substring(8);
      return false;
    }
  });
  var $fieldToConfirm = $field.closest('form').find('input[name=' + targetField + ']');
  return $field.val() === $fieldToConfirm.val();
};

Winbits.Forms = Winbits.Forms || {};
Winbits.Forms.validateForm = function(form) {
  var $ = Winbits.jQuery;
  var $form = Winbits.$(form);
  var $inputs = $form.find('input');
  var valid = true;
  $inputs.filter('.required').each(function(i, e) {
    valid = Winbits.Validations.validateRequiredField(e);
    return valid;
  });

  valid && $inputs.filter('.email').each(function(i, e) {
    valid = Winbits.Validations.validateEmailField(e);
    return valid;
  });

  valid && $inputs.filter('[class*=confirm-]', '[class*= confirm-]').each(function(i, e) {
    valid = Winbits.Validations.validateEmailField(e);
    return valid;
  });

  return valid;
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
      $('#winbits-widget').load(Winbits.config.widgetsUrl + '/widgets/winbits.html', function() {
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
    Winbits.jQuery.extend(Winbits.config, Winbits.userConfig || {});
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
  }

})(); // We call our anonymous function immediately
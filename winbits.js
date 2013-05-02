var console = window.console || {};
console.log = console.log || function() {};

var Winbits = Winbits || {};
Winbits.extraScriptLoaded = false;
Winbits.config = Winbits.config || {
  apiUrl: 'http://api.winbits.com/v1',
  baseUrl: 'http://api.winbits.com/widgets',
  errorFormClass: 'error-form',
  errorClass: 'error'
};

Winbits.$ = function(element) {
  return element instanceof Winbits.jQuery ? element : Winbits.jQuery(element);
};

Winbits.setCookie = function setCookie(c_name, value, exdays) {
  exdays = exdays || 7;
  var exdate = new Date();
  exdate.setDate(exdate.getDate() + exdays);
  var c_value = escape(value) + ((exdays === null) ? "" : "; expires=" + exdate.toUTCString());
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
};

Winbits.getUrlParams = function() {
  var vars = [], hash;
  var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
  for(var i = 0; i < hashes.length; i++) {
    hash = hashes[i].split('=');
    vars.push(hash[0]);
    vars[hash[0]] = hash[1];
  }
  return vars;
};

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
  Winbits.checkRegisterConfirmation($);
  var apiToken = Winbits.getCookie(Winbits.tokensDef.apiToken.cookieName);
  if (apiToken) {
    $.ajax(Winbits.config.apiUrl + '/affiliation/express-login.json', {
      type: 'POST',
      contentType: 'application/json',
      dataType: 'json',
      data: JSON.stringify({ apiToken: apiToken }),
      headers: { 'Accept-Language': 'es' },
//      xhrFields: { withCredentials: true },
      context: $,
      beforeSend: function(xhr) {
        xhr.withCredentials = true;
      },
      success: function(data) {
        console.log('express-login.json Success!');
        console.log(['data', data]);
        Winbits.applyLogin($, data.response);
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

Winbits.checkRegisterConfirmation = function($) {
  var params = Winbits.getUrlParams();
  console.log(['params', params]);
  var apiToken = params._wb_api_token;
  if (apiToken) {
    console.log(['Setting apiToken', apiToken]);
    Winbits.setCookie(Winbits.tokensDef.apiToken.cookieName, apiToken);
  }
};

Winbits.initWidgets = function($) {
  Winbits.initRegisterWidget($);
  Winbits.initLoginWidget($);
  Winbits.initLogout($);
};

Winbits.initRegisterWidget = function($) {
  $('#winbits-register-form').submit(function(e) {
    e.preventDefault();
    var $form = $(this);
    var formData = { verticalId: 1 };
    formData = Winbits.Forms.serializeForm($, $form, formData);
    $.ajax(Winbits.config.apiUrl + '/affiliation/register.json', {
      type: 'POST',
      contentType: 'application/json',
      dataType: 'json',
      data: JSON.stringify(formData),
      context: $form,
      beforeSend: function() {
//        var errors =  Winbits.Forms.validateForm($, this);
//        Winbits.Forms.renderErrors($, this, errors);
//        return errors != undefined;
        this.find('.form-errors').children().remove();
        return Winbits.validateRegisterForm(this);
      },
      headers: { 'Accept-Language': 'es' },
      success: function(data) {
        console.log('Request Success!');
        console.log(['data', data]);
        if (!data.response.active) {
          Winbits.showRegisterConfirmation($);
        }
      },
      error: function(xhr, textStatus, errorThrown) {
        var error = JSON.parse(xhr.responseText);
        Winbits.renderRegisterFormErrors(this, error);
      },
      complete: function() {
        console.log('Request Completed!');
      }
    });
  });
};

Winbits.validateRegisterForm = function(form) {
  var valid = true;
  var $form = Winbits.$(form);
  $form.removeClass(Winbits.config.errorFormClass);
  var $email = $form.find('input[name=email]');
  var email = ($email.val() || '').trim();
  var $emailHolder = $email.parent();
  $emailHolder.removeClass(Winbits.config.errorClass);
  if (email.length === 0 || !Winbits.Validations.emailRegEx.test(email)) {
    console.log('invalid email');
    $form.addClass(Winbits.config.errorFormClass);
    $emailHolder.addClass(Winbits.config.errorClass);
    valid = false;
  }
  var $password = $form.find('input[name=password]');
  var password = $password.val() || '';
  var $passwordHolder = $password.parent();
  $passwordHolder.removeClass(Winbits.config.errorClass);
  if (password.length === 0) {
    console.log('invalid password');
    $form.addClass(Winbits.config.errorFormClass);
    $passwordHolder.addClass(Winbits.config.errorClass);
    valid = false;
  }
  var $passwordConfirm = $form.find('input[name=passwordConfirm]');
  var passwordConfirm = $passwordConfirm.val() || '';
  var $passwordConfirmHolder = $passwordConfirm.parent();
  $passwordConfirmHolder.removeClass(Winbits.config.errorClass);
  if (passwordConfirm.length === 0 || password !== passwordConfirm) {
    console.log('invalid password confirm');
    $form.addClass(Winbits.config.errorFormClass);
    $passwordConfirmHolder.addClass(Winbits.config.errorClass);
    valid = false;
  }

  return valid;
};

Winbits.renderRegisterFormErrors = function(form, error) {
  var $form = Winbits.$(form);
  if (error.meta.code === 'AFER001') {
    $form.find('.form-errors').append('<span class="error-text visible">' + error.meta.message + '</span>');
  }
};

Winbits.showRegisterConfirmation = function($) {
  $.fancybox.close();
  setTimeout(function(){
    $('a[href=#winbits-register-confirm-popup]').click();
  }, 1000);
};

Winbits.initLoginWidget = function($) {
  $('#winbits-login-form').submit(function(e) {
    e.preventDefault();
    var $form = $(this);
    var formData = { verticalId: 1 };
    formData = Winbits.Forms.serializeForm($, $form, formData);
    $.ajax(Winbits.config.apiUrl + '/affiliation/login.json', {
      type: 'POST',
      contentType: 'application/json',
      dataType: 'json',
      data: JSON.stringify(formData),
//      xhrFields: { withCredentials: true },
      context: $form,
      beforeSend: function(xhr) {
        xhr.withCredentials = true;
        this.find('.form-errors').children().remove();
        return Winbits.validateLoginForm(this);
      },
      headers: { 'Accept-Language': 'es' },
      success: function(data) {
        console.log('Request Success!');
        console.log(['data', data]);
        Winbits.applyLogin($, data.response);
      },
      error: function(xhr, textStatus, errorThrown) {
        console.log(xhr);
        var error = JSON.parse(xhr.responseText);
        Winbits.renderLoginFormErrors(this, error);
      },
      complete: function() {
        console.log('Request Completed!');
      }
    });
  });
};

Winbits.validateLoginForm = function(form) {
  var valid = true;
  var $form = Winbits.$(form);
  $form.removeClass(Winbits.config.errorFormClass);
  var $email = $form.find('input[name=email]');
  var email = ($email.val() || '').trim();
  var $emailHolder = $email.parent();
  $emailHolder.removeClass(Winbits.config.errorClass);
  if (email.length === 0 || !Winbits.Validations.emailRegEx.test(email)) {
    console.log('invalid email');
    $form.addClass(Winbits.config.errorFormClass);
    $emailHolder.addClass(Winbits.config.errorClass);
    valid = false;
  }
  var $password = $form.find('input[name=password]');
  var password = $password.val() || '';
  var $passwordHolder = $password.parent();
  $passwordHolder.removeClass(Winbits.config.errorClass);
  if (password.length === 0) {
    console.log('invalid password');
    $form.addClass(Winbits.config.errorFormClass);
    $passwordHolder.addClass(Winbits.config.errorClass);
    valid = false;
  }

  return valid;
};

Winbits.renderLoginFormErrors = function(form, error) {
  var $ = Winbits.jQuery;
  var $form = Winbits.$(form);
  if (error.meta.code === 'AFER004') {
    var $resendConfirmLink = $('<a href="' + error.response.resendConfirmUrl + '">Reenviar correo de confirmaci&oacute;n</a>');
    $resendConfirmLink.click(function(e) {
      e.preventDefault();
      Winbits.resendConfirmLink($, e.target);
    });
    var $errorMessageHolder = $('<span class="error-text visible">' + error.meta.message + '. <span class="link-holder"></span></span>');
    $errorMessageHolder.find('.link-holder').append($resendConfirmLink);
    $form.find('.form-errors').append($errorMessageHolder);
  } else {
    $form.find('.form-errors').append('<span class="error-text visible">' + error.meta.message + '</span>');
  }
};

Winbits.resendConfirmLink = function($, link) {
  var $link = Winbits.$(link);
  var url = $link.attr('href');
  $.ajax(url, {
    dataType: 'json',
    headers: { 'Accept-Language': 'es' },
    success: function(data) {
      console.log('resendConfirm Success!');
      console.log(['data', data]);
      Winbits.showRegisterConfirmation($);
    },
    error: function(xhr, textStatus, errorThrown) {
      var error = JSON.parse(xhr.responseText);
      alert(error.response.message);
    },
    complete: function() {
      console.log('resendConfirm Completed!');
    }
  });
};

Winbits.applyLogin = function($, profile) {
  Winbits.showCompleteProfileIfRegister($);
  console.log('Logged In');
  Winbits.setCookie(Winbits.tokensDef.apiToken.cookieName, profile.apiToken);
  $('#winbits-login-link').text('Checkout');
  var $mainLinks = $('#winbits-main-links');
  $mainLinks.children('.offline').hide();
  $mainLinks.children('.online').show();
};

Winbits.showCompleteProfileIfRegister = function($) {
  var params = Winbits.getUrlParams();
  var registerConfirmation = params._wb_register_confirm;
  if (registerConfirmation) {
    $('a[href=#winbits-complete-profile-popup]').click();
  }
};

Winbits.initLogout = function($) {
  $('#winbits-logout-link').click(function(e) {
    e.preventDefault();
    $.ajax(Winbits.config.apiUrl + '/affiliation/logout.json', {
      type: 'POST',
      contentType: 'application/json',
      dataType: 'json',
      data: JSON.stringify(formData),
//      xhrFields: { withCredentials: true },
      beforeSend: function(xhr) {
        xhr.withCredentials = true;
      },
      headers: { 'Accept-Language': 'es' },
      success: function(data) {
        console.log('logout.json Success!');
        console.log(['data', data]);
        Winbits.applyLogout($);
      },
      error: function(xhr, textStatus, errorThrown) {
        console.log('logout.json Error!');
        var error = JSON.parse(xhr.responseText);
        alert(error.meta.message);
      },
      complete: function() {
        console.log('logout.json Completed!');
      }
    });
  });
};

Winbits.applyLogout = function($) {
  console.log('Logging out');
  Winbits.setCookie(Winbits.tokensDef.apiToken.cookieName, '');
  $('#winbits-login-link').text('Log In');
  var $mainLinks = $('#winbits-main-links');
  $mainLinks.children('.offline').show();
  $mainLinks.children('.online').hide();
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
Winbits.Forms.serializeForm = function($, form, context){
  var formData = context || {};
  var $form = Winbits.$(form);
  $.each($form.serializeArray(), function(i, f) {
    formData[f.name] = f.value;
  });
  return formData;
};

Winbits.Forms.validateForm = function($, form) {
  var $form = Winbits.$(form);
  var $inputs = $form.find('input');
  var errors = {};
  $inputs.filter('.required').each(function(i, input) {
    var $input = Winbits.$(input);
    var name = $input.attr('name'); 
    errors[name] = errors[name] || [];
    if (Winbits.Validations.validateRequiredField($input)) {
      errors[name].push('required');
    }
  });

  $inputs.filter('.email').each(function(i, input) {
    var $input = Winbits.$(input);
    var name = $input.attr('name');
    errors[name] = errors[name] || [];
    if (Winbits.Validations.validateRequiredField($input)) {
      errors[name].push('email');
    }
  });

  $inputs.filter('[class*=confirm-]', '[class*= confirm-]').each(function(i, input) {
    var $input = Winbits.$(input);
    var name = $input.attr('name');
    errors[name] = errors[name] || [];
    if (Winbits.Validations.validateRequiredField($input)) {
      errors[name].push('confirm');
    }
  });

  return errors;
};

Winbits.Forms.renderErrors = function ($, form, errors) {

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
      $('#winbits-widget').load(Winbits.config.baseUrl + '/widgets/winbits.html', function() {
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
    $head.append('<link rel="stylesheet" type="text/css" media="all" href="' + Winbits.config.baseUrl + '/css/fancybox.css"/>');
    $head.append('<link rel="stylesheet" type="text/css" media="all" href="' + Winbits.config.baseUrl + '/css/all.css"/>');
    $head.append('<!--[if lt IE 9]><link rel="stylesheet" type="text/css" href="' + Winbits.config.baseUrl + '/css/ie.css" /><![endif]-->');
    Winbits._readyInterval = window.setInterval(function() {
      Winbits.winbitsReady();
    }, 50);
  }

  function createExtraScriptTag() {
    var scriptTag = document.createElement('script');
    scriptTag.setAttribute("type","text/javascript");
    scriptTag.setAttribute("src", Winbits.config.baseUrl + "/js/jquery.main.js");
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
    var headTag = (document.getElementsByTagName("head")[0] || document.documentElement);
    headTag.appendChild(scriptTag);
  }

})(); // We call our anonymous function immediately
var console = window.console || {};
console.log = console.log || function () {};

var Winbits = Winbits || {};
Winbits.extraScriptLoaded = false;
Winbits.facebookLoaded = false;
Winbits.config = Winbits.config || {
  apiUrl: 'http://api.winbits.com/v1',
  baseUrl: 'http://api.winbits.com/widgets',
  loginRedirectUrl: 'http://api.winbits.com/widgets/login.html',
  errorFormClass: 'error-form',
  errorClass: 'error',
  verticalId: 1
};

Winbits.$ = function (element) {
  return element instanceof Winbits.jQuery ? element : Winbits.jQuery(element);
};

Winbits.setCookie = function setCookie(c_name, value, exdays) {
  exdays = exdays || 7;
  var exdate = new Date();
  exdate.setDate(exdate.getDate() + exdays);
  var c_value = escape(value) + ((exdays === null) ? "" : "; path=/; expires=" + exdate.toUTCString());
  document.cookie = c_name + "=" + c_value;
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
    c_value = unescape(c_value.substring(c_start, c_end));
  }
  return c_value;
};

Winbits.deleteCookie = function (name) {
  document.cookie = name + '=; path=/; expires=Thu, 01 Jan 1970 00:00:01 GMT';
};

Winbits.getUrlParams = function () {
  var vars = [], hash;
  var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
  for (var i = 0; i < hashes.length; i++) {
    hash = hashes[i].split('=');
    vars.push(hash[0]);
    vars[hash[0]] = hash[1];
  }
  return vars;
};

Winbits.waitForFacebook = function(f, $) {
  console.log(['Winbits.facebookLoaded', Winbits.facebookLoaded]);
  if (Winbits.facebookLoaded) {
    f($);
  } else {
    setTimeout(function() {
      Winbits.waitForFacebook(f, $);
    }, 10);
  }
};

Winbits.init = function () {
  var $ = Winbits.jQuery;
  Winbits.requestTokens($);
  Winbits.initWidgets($);
  Winbits.alertErrors($);
  $('form.lightbox-message-form').submit(function (e) {
    e.preventDefault();
    $.fancybox.close();
  });
};

Winbits.alertErrors = function ($) {
  var params = Winbits.getUrlParams();
  if (params._wb_error) {
    alert(params._wb_error);
  }
};

Winbits.requestTokens = function ($) {
  $.ajax(Winbits.config.apiUrl + '/affiliation/tokens.json', {
    dataType: 'json',
    context: $,
    xhrFields: { withCredentials: true },
    success: function (data) {
      console.log('tokens.json Success!');
      console.log(['data', data]);
      Winbits.segregateTokens(this, data.response);
      Winbits.expressLogin(this);
    },
    error: function (xhr, textStatus, errorThrown) {
      console.log('tokens.json Error!');
      var error = JSON.parse(xhr.responseText);
      alert(error.meta.message);
    }
  });
};

Winbits.segregateTokens = function ($, tokensDef) {
  Winbits.storeTokens($, tokensDef);
  var guestTokenDef = tokensDef.guestToken;
  Winbits.setCookie(guestTokenDef.cookieName, guestTokenDef.value || '', guestTokenDef.expireDays);
  var apiTokenDef = tokensDef.apiToken;
  Winbits.setCookie(apiTokenDef.cookieName, apiTokenDef.value || '', apiTokenDef.expireDays);
  Winbits.tokensDef = tokensDef;
};

Winbits.storeTokens = function ($, tokensDef) {
  var tokens = [];
  var guestToken = tokensDef.guestToken;
  if (guestToken.value) {
    tokens.push(['_wb_guest_token', guestToken.value].join('='));
  }
  var apiToken = tokensDef.apiToken;
  if (apiToken.value) {
    tokens.push(['_wb_api_token', apiToken.value].join('='));
  }

  if (tokens.length > 0) {
    var tokensQueryString = tokens.join('&');
    var storeCookiesUrl = Winbits.config.loginRedirectUrl + '?' + tokensQueryString;
    Winbits.createFrame($, storeCookiesUrl);
  }
};

Winbits.createFrame = function ($, frameSrc) {
  var $iframe = $('<iframe></iframe>');
  $iframe.appendTo('#winbits-iframe-holder');
  $iframe.attr('src', frameSrc);
  $iframe.load(function (e) {
    $(e.target).remove();
  });
};

Winbits.expressLogin = function ($) {
  Winbits.checkRegisterConfirmation($);
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
      success: function (data) {
        console.log('express-login.json Success!');
        console.log(['data', data]);
        Winbits.applyLogin($, data.response);
      },
      error: function (xhr, textStatus, errorThrown) {
        console.log('express-login.json Error!');
        var error = JSON.parse(xhr.responseText);
        alert(error.meta.message);
      }
    });
  } else {
    Winbits.expressFacebookLogin($);
  }
};

Winbits.checkRegisterConfirmation = function ($) {
  var params = Winbits.getUrlParams();
  console.log(['params', params]);
  var apiToken = params._wb_api_token;
  if (apiToken) {
    console.log(['Setting apiToken', apiToken]);
    Winbits.setCookie(Winbits.tokensDef.apiToken.cookieName, apiToken);
  }
};

Winbits.expressFacebookLogin = function ($) {
  Winbits.waitForFacebook(function($) {
    console.log('About to call FB.getLoginStatus.');
    FB.getLoginStatus(function(response) {
      console.log(['FB.getLoginStatus', response]);
      if (response.status == 'connected') {
      $.ajax(Winbits.config.apiUrl + '/affiliation/express-facebook-login.json', {
          type: 'POST',
          contentType: 'application/json',
          dataType: 'json',
          data: JSON.stringify({ facebookId: response.authResponse.userID }),
          headers: { 'Accept-Language': 'es' },
          xhrFields: { withCredentials: true },
          context: $,
          success: function (data) {
            console.log('express-facebook-login.json Success!');
            console.log(['data', data]);
            Winbits.applyLogin($, data.response);
          },
          error: function (xhr, textStatus, errorThrown) {
            console.log('express-facebook-login.json Error!');
          }
        });
      }
    }, true);
  }, $);
};

Winbits.initWidgets = function ($) {
  Winbits.initRegisterWidget($);
  Winbits.initLoginWidget($);
  Winbits.initFacebookWidgets($);
  Winbits.initLogout($);
};

Winbits.initRegisterWidget = function ($) {
  $('#winbits-register-form').submit(function (e) {
    e.preventDefault();
    var $form = $(this);
    var formData = { verticalId: Winbits.config.verticalId };
    formData = Winbits.Forms.serializeForm($, $form, formData);
    $.ajax(Winbits.config.apiUrl + '/affiliation/register.json', {
      type: 'POST',
      contentType: 'application/json',
      dataType: 'json',
      data: JSON.stringify(formData),
      context: $form,
      beforeSend: function () {
        this.find('.form-errors').children().remove();
        return Winbits.validateRegisterForm(this);
      },
      headers: { 'Accept-Language': 'es' },
      success: function (data) {
        console.log('Request Success!');
        console.log(['data', data]);
        if (!data.response.active) {
          Winbits.showRegisterConfirmation($);
        }
      },
      error: function (xhr, textStatus, errorThrown) {
        var error = JSON.parse(xhr.responseText);
        Winbits.renderRegisterFormErrors(this, error);
      },
      complete: function () {
        console.log('Request Completed!');
      }
    });
  });
};

Winbits.validateRegisterForm = function (form) {
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

Winbits.renderRegisterFormErrors = function (form, error) {
  var $form = Winbits.$(form);
  if (error.meta.code === 'AFER001') {
    $form.find('.form-errors').append('<span class="error-text visible">' + error.meta.message + '</span>');
  }
};

Winbits.showRegisterConfirmation = function ($, profile) {
  setTimeout(function () {
    $('a[href=#winbits-register-confirm-popup]').click();
  }, 1000);
};

Winbits.loadProfile = function($, profile) {
  console.log(['Loading profile', profile]);
  if (profile) {
    var $profileForm = $('form#complete-profile-form');
    $profileForm.find('input[name=firstName]').val(profile.name);
    $profileForm.find('input[name=lastName]').val(profile.lastName);
    if (profile.birthdate) {
      var birthday = profile.birthdate.split('-');
      var year = birthday[0];
      year = year.length > 2 ? year.substr(2) : year;
      $profileForm.find('input[name="birthday.day"]').val(birthday[2]);
      $profileForm.find('input[name="birthday.month"]').val(birthday[1]);
      $profileForm.find('input[name="birthday.year"]').val(year);
    }
    if (profile.gender) {
      $profileForm.find('a.radio-item.gender-' + profile.gender).addClass('selected');
    }
  }
};

Winbits.initLoginWidget = function ($) {
  $('#winbits-login-form').submit(function (e) {
    e.preventDefault();
    var $form = $(this);
    var formData = { verticalId: Winbits.config.verticalId };
    formData = Winbits.Forms.serializeForm($, $form, formData);
    $.ajax(Winbits.config.apiUrl + '/affiliation/login.json', {
      type: 'POST',
      contentType: 'application/json',
      dataType: 'json',
      data: JSON.stringify(formData),
      xhrFields: { withCredentials: true },
      context: $form,
      beforeSend: function (xhr) {
        this.find('.form-errors').children().remove();
        return Winbits.validateLoginForm(this);
      },
      headers: { 'Accept-Language': 'es' },
      success: function (data) {
        console.log('Request Success!');
        console.log(['data', data]);
        Winbits.applyLogin($, data.response);
        $.fancybox.close();
      },
      error: function (xhr, textStatus, errorThrown) {
        console.log(xhr);
        var error = JSON.parse(xhr.responseText);
        Winbits.renderLoginFormErrors(this, error);
      },
      complete: function () {
        console.log('Request Completed!');
      }
    });
  });
};

Winbits.validateLoginForm = function (form) {
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

Winbits.renderLoginFormErrors = function (form, error) {
  var $ = Winbits.jQuery;
  var $form = Winbits.$(form);
  if (error.meta.code === 'AFER004') {
    var $resendConfirmLink = $('<a href="' + error.response.resendConfirmUrl + '">Reenviar correo de confirmaci&oacute;n</a>');
    $resendConfirmLink.click(function (e) {
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

Winbits.resendConfirmLink = function ($, link) {
  var $link = Winbits.$(link);
  var url = $link.attr('href');
  $.ajax(url, {
    dataType: 'json',
    headers: { 'Accept-Language': 'es' },
    success: function (data) {
      console.log('resendConfirm Success!');
      console.log(['data', data]);
      Winbits.showRegisterConfirmation($);
    },
    error: function (xhr, textStatus, errorThrown) {
      var error = JSON.parse(xhr.responseText);
      alert(error.response.message);
    },
    complete: function () {
      console.log('resendConfirm Completed!');
    }
  });
};

Winbits.applyLogin = function ($, profile) {
  Winbits.showCompleteProfileIfRegister($);
  console.log('Logged In');
  Winbits.tokensDef.apiToken.value = profile.apiToken;
  Winbits.storeTokens($, Winbits.tokensDef);
  Winbits.setCookie(Winbits.tokensDef.apiToken.cookieName, profile.apiToken);
  $('#winbits-login-link').text('Checkout');
  $('#winbits-bits-balance').text(profile.bitsBalance);
  $('#winbits-email').text(profile.email);
  var $mainLinks = $('#winbits-main-links');
  $mainLinks.children('.offline').hide();
  $mainLinks.children('.online').show();
};

Winbits.showCompleteProfileIfRegister = function ($) {
  var params = Winbits.getUrlParams();
  var registerConfirmation = params._wb_register_confirm;
  if (registerConfirmation) {
    Winbits.showCompleteProfile($);
  }
};

Winbits.showCompleteProfile = function ($, profile) {
  $.fancybox.close();
  Winbits.loadProfile($, profile);
  $('a[href=#winbits-complete-profile-popup]').click();
};

Winbits.initFacebookWidgets = function($) {
  $(".btn-facebook").click(function () {
    console.log("click a boton de facebok");
    FB.login(Winbits.loginFacebookHandler, {scope: 'email,user_about_me,user_birthday'});
    return false;
  });
};

Winbits.initLogout = function ($) {
  $('#winbits-logout-link').click(function (e) {
    e.preventDefault();
    $.ajax(Winbits.config.apiUrl + '/affiliation/logout.json', {
      type: 'POST',
      contentType: 'application/json',
      dataType: 'json',
      xhrFields: { withCredentials: true },
      headers: { 'Accept-Language': 'es' },
      success: function (data) {
        console.log('logout.json Success!');
        Winbits.applyLogout($, data.response);
      },
      error: function (xhr, textStatus, errorThrown) {
        console.log('logout.json Error!');
        var error = JSON.parse(xhr.responseText);
        alert(error.meta.message);
      },
      complete: function () {
        console.log('logout.json Completed!');
      }
    });
  });
};

Winbits.applyLogout = function ($, logoutData) {
  Winbits.deleteCookie(Winbits.tokensDef.apiToken.cookieName);
  Winbits.createFrame($, logoutData.logoutRedirectUrl);
  $('#winbits-login-link').text('Log In');
  var $mainLinks = $('#winbits-main-links');
  $mainLinks.children('.offline').show();
  $mainLinks.children('.online').hide();
  FB.logout(function(response) {
    console.log(['Facebook logout', response]);
  });
};

Winbits.resetLightBoxes = function ($, scope) {
  var $lightbox = $(scope.href);
  $lightbox.find('form').each(function (i, form) {
    console.log(['form', form]);
    var $form = $(form);
    $form.removeClass(Winbits.config.errorFormClass);
    $form.find('.form-errors').children().remove();
    $form.find('input[type=text], input[type=password]').each(function (j, input) {
      var $input = $(input);
      $input.parent().removeClass(Winbits.config.errorClass);
      $input.val('');
    });
//    form.reset();
  });
};

Winbits.Validations = Winbits.Validations || {};
Winbits.Validations.emailRegEx = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
Winbits.Validations.validateRequiredField = function (field) {
  var $ = Winbits.jQuery;
  var $field = Winbits.$(field);
  var fieldValue = $field.val() || '';
  return fieldValue.length > 0;
};
Winbits.Validations.validateEmailField = function (field) {
  var $ = Winbits.jQuery;
  var $field = Winbits.$(field);
  var fieldValue = $field.val() || '';
  return Winbits.Validations.emailRegEx.test(fieldValue);
};
Winbits.Validations.validateConfirmField = function (field) {
  var $ = Winbits.jQuery;
  var $field = Winbits.$(field);
  var targetField;
  $.each($field.attr('class').split(/\s+/), function (i, className) {
    if (className.indexOf('confirm-') === 0) {
      targetField = className.substring(8);
      return false;
    }
  });
  var $fieldToConfirm = $field.closest('form').find('input[name=' + targetField + ']');
  return $field.val() === $fieldToConfirm.val();
};

Winbits.Forms = Winbits.Forms || {};
Winbits.Forms.serializeForm = function ($, form, context) {
  var formData = context || {};
  var $form = Winbits.$(form);
  $.each($form.serializeArray(), function (i, f) {
    formData[f.name] = f.value;
  });
  return formData;
};

Winbits.Forms.validateForm = function ($, form) {
  var $form = Winbits.$(form);
  var $inputs = $form.find('input');
  var errors = {};
  $inputs.filter('.required').each(function (i, input) {
    var $input = Winbits.$(input);
    var name = $input.attr('name');
    errors[name] = errors[name] || [];
    if (Winbits.Validations.validateRequiredField($input)) {
      errors[name].push('required');
    }
  });

  $inputs.filter('.email').each(function (i, input) {
    var $input = Winbits.$(input);
    var name = $input.attr('name');
    errors[name] = errors[name] || [];
    if (Winbits.Validations.validateRequiredField($input)) {
      errors[name].push('email');
    }
  });

  $inputs.filter('[class*=confirm-]', '[class*= confirm-]').each(function (i, input) {
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

Winbits.loadFacebook = function () {
 /* window.fbAsyncInit = function () {
    FB.init({appId: '486640894740634', status: true, cookie: true, xfbml: true});
    console.log('FB.init called.');
    Winbits.facebookLoaded = true;
  };*/
  (function () {
    var e = document.createElement('script');
    e.async = true;
    e.src = 'http://connect.facebook.net/en_US/all.js';
    (document.getElementsByTagName('head')[0] || document.documentElement).appendChild(e);
  }());
};

Winbits.loginFacebookHandler = function (response) {
  console.log("Se dio click");
  console.log(['FB.login respose', response]);
  if (response.authResponse) {
    FB.api('/me', function (me) {
      console.log(['FB.me respose', me]);
      if (me.email) {
        Winbits.loginFacebook(me);
      }
    });
  } else {
    console.log('User cancelled login or did not fully authorize.');
  }
};

Winbits.loginFacebook = function(me) {
  var $ = Winbits.jQuery;
  var myBirthdayDate = new Date(me.birthday);
  var birthday = myBirthdayDate.getDate() + "/" + myBirthdayDate.getMonth() + "/" + myBirthdayDate.getFullYear();
  var payLoad = {
    name: me.first_name,
    lastName: me.last_name,
    email: me.email,
    birthdate: birthday,
    gender: me.gender,
    verticalId: Winbits.config.verticalId,
    locale: me.locale,
    facebookId: me.id,
    facebookToken: me.id
  };
  $.fancybox.close();
  $.ajax(Winbits.config.apiUrl + '/affiliation/facebook', {
    type: 'POST',
    contentType: 'application/json',
    dataType: 'json',
    data: JSON.stringify(payLoad),
    xhrFields: { withCredentials: true },
    headers: { 'Accept-Language': 'es' },
    success: function (data) {
      console.log('facebook.json success!');
      console.log(['data', data]);
      Winbits.applyLogin($, data.response);
      if (201 == data.meta.status) {
        console.log('Facebook registered');
        Winbits.showCompleteProfile($, data.response.profile);
      }
    },
    error: function (xhr, textStatus, errorThrown) {
      console.log('facebook.json error!');
      var error = JSON.parse(xhr.responseText);
      alert(error.meta.message);
    }
  });
};

(function () {
  // Localize jQuery variable
  Winbits.jQuery;

  // Async load facebook
  Winbits.loadFacebook();

  /******** Load jQuery if not present *********/
  if (window.jQuery === undefined || window.jQuery.fn.jquery !== '1.8.3') {
    var scriptTag = document.createElement('script');
    scriptTag.setAttribute("type", "text/javascript");
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
    (document.getElementsByTagName('head')[0] || document.documentElement).appendChild(scriptTag);
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
      $('#winbits-widget').load(Winbits.config.baseUrl + '/widgets/winbits.html', function () {
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
    Winbits._readyInterval = window.setInterval(function () {
      Winbits.winbitsReady();
    }, 50);
  };

  function createExtraScriptTag() {
    var scriptTag = document.createElement('script');
    scriptTag.setAttribute("type", "text/javascript");
    scriptTag.setAttribute("src", Winbits.config.baseUrl + "/js/jquery.main.js");
    if (scriptTag.readyState) {
      scriptTag.onreadystatechange = function () { // For old versions of IE
        if (this.readyState == 'complete' || this.readyState == 'loaded') {
          Winbits.extraScriptLoaded = true;
        }
      };
    } else {
      scriptTag.onload = function () {
        Winbits.extraScriptLoaded = true;
      };
    }
    // Try to find the head, otherwise default to the documentElement
    var headTag = (document.getElementsByTagName("head")[0] || document.documentElement);
    headTag.appendChild(scriptTag);
  }

})(); // We call our anonymous function immediately

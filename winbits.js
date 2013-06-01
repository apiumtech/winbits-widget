var console = window.console || {};
console.log = console.log || function () {};

var Winbits = Winbits || {};
Winbits.extraScriptLoaded = false;
Winbits.facebookLoaded = false;
Winbits.config = Winbits.config || {
  apiUrl: 'http://apiqa.winbits.com/v1',
  baseUrl: 'http://api.winbits.com/widgets',
  loginRedirectUrl: 'http://api.winbits.com/widgets/ilogin.html',
  errorFormClass: 'error-form',
  errorClass: 'error',
  verticalId: 1,
  proxyUrl : "-",
  winbitsDivId: 'winbits-widget'
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
};

Winbits.initProxy = function($) {
  var iframeSrc = Winbits.config.baseUrl +'/winbits.html?origin=' + Winbits.config.proxyUrl;
  var iframeStyle = 'width:100%;border: 0px;overflow: hidden;';
  var $iframe = $('<iframe id="winbits-iframe" name="winbits-iframe" height="30" style="' + iframeStyle + '" src="' + iframeSrc +'"></iframe>').on('load', function() {
    if (!Winbits.initialized) {
      Winbits.initialized = true;
      Winbits.init();
    }
  });
  Winbits.$widgetContainer.find('#iframe-holder').append($iframe);

  // Create a proxy window to send to and receive
  // messages from the iFrame
  Winbits.proxy = new Porthole.WindowProxy(Winbits.config.baseUrl + '/proxy.html', 'winbits-iframe');

  // Register an event handler to receive messages;
  Winbits.proxy.addEventListener(function (messageEvent) {
    console.log(['Message from Winbits', messageEvent]);
    var data = messageEvent.data;
    var handlerFn = Winbits.Handlers[data.action + 'Handler'];
    if (handlerFn) {
      handlerFn.apply(this, data.params);
    } else {
      console.log('Invalid action from Winbits');
    }
  });
};

Winbits.alertErrors = function ($) {
  var params = Winbits.getUrlParams();
  if (params._wb_error) {
    alert(params._wb_error);
  }
};

Winbits.requestTokens = function ($) {
  console.log('Requesting tokens');
  Winbits.proxy.post({ action: 'getTokens' });
};

Winbits.segregateTokens = function ($, tokensDef) {
  console.log(['tokensDef', tokensDef]);
  var vcartTokenDef = tokensDef.vcartToken;
  Winbits.setCookie(vcartTokenDef.cookieName, vcartTokenDef.value || '', vcartTokenDef.expireDays);
  var apiTokenDef = tokensDef.apiToken;
  if (apiTokenDef) {
    Winbits.setCookie(apiTokenDef.cookieName, apiTokenDef.value || '', apiTokenDef.expireDays);
  } else {
    tokensDef.apiToken = {cookieName: '_wb_api_token', expireDays: 7}
  }
  Winbits.tokensDef = tokensDef;
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
  var apiToken = params._wb_api_token;
  if (apiToken) {
    console.log('API token found as parameter, saving...');
    Winbits.saveApiToken(apiToken);
  }
};

Winbits.saveApiToken = function(apiToken) {
  Winbits.tokensDef.apiToken.value = apiToken;
  Winbits.setCookie(Winbits.tokensDef.apiToken.cookieName, apiToken, 7);
  Winbits.proxy.post({ action: 'saveApiToken', params: [apiToken] });
};

Winbits.expressFacebookLogin = function ($) {
  Winbits.proxy.post({ action: 'facebookStatus' });
};

Winbits.initWidgets = function ($) {
  Winbits.initLightbox($);
  Winbits.initControls($);
  Winbits.initRegisterWidget($);
  Winbits.initLoginWidget($);
//  Winbits.initLogout($);
};

Winbits.initControls = function($) {
  Winbits.$widgetContainer.find(":input[placeholder]").placeholder();
  Winbits.$widgetContainer.find('form').validate();
  changeShippingAddress({
    obj: '.shippingAddresses',
    objetivo: '.shippingItem',
    activo: 'shippingSelected',
    inputradio: '.shippingRadio'
  });
  customCheckbox('.checkbox');
  customRadio('.divGender');
  customSelect ('.select');
  customSlider('.slideInput');
  customStepper('.inputStepper');
  dropMenu({
    obj: '.miCuentaDiv',
    clase: '.dropMenu',
    trigger: '.triggerMiCuenta',
    other: '.miCarritoDiv'
  });
  dropMenu({
    obj: '.miCarritoDiv',
    clase: '.dropMenu',
    trigger: '.shopCarMin',
    other: '.miCuentaDiv'
  });
  openFolder({
    obj: '.knowMoreMin',
    trigger: '.knowMoreMin .openClose',
    objetivo: '.knowMoreMax'
  });
  openFolder({
    obj: '.knowMoreMax',
    trigger: '.knowMoreMax .openClose',
    objetivo: '.knowMoreMin'
  });
  openFolder({
    obj: '.myProfile .miPerfil',
    trigger:  '.myProfile .miPerfil .editBtn',
    objetivo: '.myProfile .editMiPerfil'
  });
  openFolder({
    obj: '.myProfile .editMiPerfil',
    trigger: '.myProfile .editMiPerfil .editBtn',
    objetivo: '.myProfile .miPerfil'
  });
  openFolder({
    obj: '.myProfile .miPerfil',
    trigger: '.myProfile .miPerfil .changePassBtn',
    objetivo: '.myProfile .changePassDiv'
  });
  openFolder({
    obj: '.myProfile .changePassDiv',
    trigger: '.myProfile .changePassDiv .editBtn',
    objetivo: '.myProfile .miPerfil'
  });
  openFolder({
    obj: '.myAddress .miDireccion',
    trigger: '.myAddress .miDireccion .editBtn, .myAddress .miDireccion .changeAddressBtn',
    objetivo: '.myAddress .editMiDireccion'
  });
  openFolder({
    obj: '.myAddress .editMiDireccion',
    trigger: '.myAddress .editMiDireccion .editBtn',
    objetivo: '.myAddress .miDireccion'
  });
  openFolder({
    obj: '.mySuscription .miSuscripcion',
    trigger: '.mySuscription .miSuscripcion .editBtn, .mySuscription .miSuscripcion .editLink',
    objetivo: '.mySuscription .editSuscription'
  });
  openFolder({
    obj: '.mySuscription .editSuscription',
    trigger: '.mySuscription .editSuscription .editBtn',
    objetivo: '.mySuscription .miSuscripcion'
  });
  openFolder({
    obj: '.shippingAddresses',
    trigger: '.shippingAdd',
    objetivo: '.shippingNewAddress'
  });
  openFolder({
    obj: '.shippingNewAddress',
    trigger: '.submitButton .btnCancel',
    objetivo: '.shippingAddresses'
  });
//  placeholder('input[type="text"], input[type="password"]');
  sendEmail('.btnSmall');
//  validar({
//    container: '.bodyModal',
//    form: '.bodyModal form',
//    errorClass: 'errorInputError',
//    errorElement: 'span',
//    errorLabel: '.errorDiv p',
//    classSuccess: 'errorInputOK'
//  });
  verticalCarousel('.carritoDivLeft .carritoContainer');
  console.log('Winibits Initialized');
};

Winbits.initLightbox = function($) {
  Winbits.$widgetContainer.find('a.fancybox').fancybox({
    overlayShow: true,
    hideOnOverlayClick: true,
    enableEscapeButton: true,
    showCloseButton: true,
    overlayOpacity: 0.9,
    overlayColor: '#333',
    padding: 0,
    type: 'inline',
    onComplete: function() {
      var $layer = $(this.href);
      $layer.find('form').first().find('input.default').focus();
      var $holder = $layer.find('.facebook-btn-holder');
      if ($holder.length > 0) {
        $('#winbits-iframe').appendTo($holder);
      }
    },
    onCleanup: function() {
      $(this.href).find('form').each(function(i, form) {
        var $form = $(form);
        $form.find('.errors').html('');
        $form.validate().resetForm();
        form.reset();
      });
      var $holder = Winbits.$widgetContainer.find('#iframe-holder');
      $('#winbits-iframe').appendTo($holder);
    }
  });
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
        return Winbits.validateForm(this);
      },
      headers: { 'Accept-Language': 'es' },
      success: function (data) {
        console.log('Request Success!');
        console.log(['data', data]);
        $.fancybox.close();
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

Winbits.validateForm = function(form) {
  var $form = Winbits.$(form);
  $form.find('.errors').html('');
  return $form.valid();
};

Winbits.renderRegisterFormErrors = function (form, error) {
  var $form = Winbits.$(form);
  var code = error.code || error.meta.code;
  if (code === 'AFER001') {
    var message = error.message || error.meta.message;
    $form.find('.errors').html('<p>' + message + '</p>');
  }
};

Winbits.showRegisterConfirmation = function ($) {
  setTimeout(function () {
    $('a[href=#register-confirm-layer]').click();
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
  Winbits.saveApiToken(profile.apiToken);
  Winbits.$widgetContainer.find('div.login').hide();
  Winbits.$widgetContainer.find('div.miCuenta').show();
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
  $('a[href=#complete-register-layer]').click();
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
  window.fbAsyncInit = function () {
    FB.init({appId: '486640894740634', status: true, cookie: true, xfbml: true});
    console.log('FB.init called.');
    Winbits.facebookLoaded = true;
  };
  (function () {
    var e = document.createElement('script');
    e.async = true;
    e.src = 'http://connect.facebook.net/en_US/all.js';
    (document.getElementsByTagName('head')[0] || document.documentElement).appendChild(e);
  }());
};

Winbits.loginFacebookHandler = function (response) {
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
  console.log("Enviando info al back");
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

Winbits.Handlers = {
  getTokensHandler: function(tokensDef) {
    Winbits.segregateTokens(Winbits.jQuery, tokensDef);
    Winbits.expressLogin(Winbits.jQuery);
  },
  facebookStatusHandler: function(response) {
    console.log(['Facebook status', response]);
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
  },
  facebookLoginHandler: function (response) {
    if (response.authResponse) {
      windowProxy.post({'action':'facebookMe'});
    } else {
      console.log('Facebook login failed!');
    }
  },
  facebookMeHandler: function (response) {
    console.log(response);
    if (response.email) {
      console.log('Trying to log with facebook');
//      Winbits.loginFacebook(response);
    }
  }
};

(function () {
  // Localize jQuery variable
  Winbits.jQuery;

  // Async load facebook
  // Winbits.loadFacebook();

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
    var $widgetContainer = Winbits.jQuery('#' + Winbits.config.winbitsDivId);
    if ($widgetContainer.length > 0) {
      window.clearInterval(Winbits._readyInterval);
      var $ = Winbits.jQuery;
      /******* Load HTML *******/
      Winbits.$widgetContainer = $widgetContainer.first();
      Winbits.$widgetContainer.load(Winbits.config.baseUrl + '/widget.html', function () {
        Winbits.$widgetContainer.append('<script type="text/javascript" src="' + Winbits.config.baseUrl  + '/include/js/script.js"></script>" ');
        Winbits.initProxy($);
      });
    }
  };

  Winbits.addToCart = function(skuProfileId, quantity, bits) {
    console.log(['Added to cart', skuProfileId, quantity]);
  };

  /******** Our main function ********/
  function main() {
    Winbits.jQuery.extend(Winbits.config, Winbits.userConfig || {});
    var $head = Winbits.jQuery('head');
    var styles = [Winbits.config.baseUrl + '/include/css/style.css'];
    /*loadStylesInto(styles, $head);
     var scripts = [
     Winbits.config.baseUrl + "/js/porthole.min.js",
     Winbits.config.baseUrl + "/include/js/libs/modernizr-2.6.2.js",
     Winbits.config.baseUrl + "/include/js/libs/jquery-1.8.3.min.js",
     Winbits.config.baseUrl + "/include/js/libs/jquery.browser.min.js",
     Winbits.config.baseUrl + "/include/js/libs/jQueryUI1.9.2/jquery-ui-1.9.2.js",
     Winbits.config.baseUrl + "/include/js/libs/Highslide/highslide.js",
     Winbits.config.baseUrl + "/include/js/libs/jquery.validate.min.js"
     ];
     Winbits.requiredScriptsCount = scripts.length;
     Winbits.loadedScriptsCount = 0;
     loadScriptsInto(scripts, $head);
     Winbits._readyRetries = 0;*/
    Winbits._readyInterval = window.setInterval(function () {
//      Winbits._readyRetries = Winbits._readyRetries + 1;
      Winbits.winbitsReady();
    }, 50);
  };

  function loadStylesInto(styles, e) {
    var $into = Winbits.$(e);
    Winbits.jQuery.each(styles, function(i, style) {
      $into.append('<link rel="stylesheet" type="text/css" media="all" href="' + style + '"/>');
    });
  };

  function loadScriptsInto(scripts, e) {
    var $into = Winbits.$(e);
    Winbits.jQuery.each(scripts, function(i, script) {
      var scriptTag = document.createElement('script');
      scriptTag.setAttribute("type", "text/javascript");
      scriptTag.setAttribute("src", script);
      if (scriptTag.readyState) {
        scriptTag.onreadystatechange = function () { // For old versions of IE
          if (this.readyState == 'complete' || this.readyState == 'loaded') {
            Winbits.loadedScriptsCount = Winbits.loadedScriptsCount + 1;
          }
        };
      } else {
        scriptTag.onload = function () {
          Winbits.loadedScriptsCount = Winbits.loadedScriptsCount + 1;
        };
      }
      $into.append(scriptTag);
    });
  };

})(); // We call our anonymous function immediately

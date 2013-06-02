var console = window.console || {};
console.log = console.log || function () {};

var Winbits = {};
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
Winbits.apiTokenName = '_wb_api_token';
Winbits.vcartTokenName = '_wb_vcart_token';
Winbits.Flags = { loggedIn: false, fbConnect: false };

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
  Winbits.$widgetContainer.find('#winbits-iframe-holder').append($iframe);

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
  Winbits.setCookie(vcartTokenDef.cookieName, vcartTokenDef.value, vcartTokenDef.expireDays);
  var apiTokenDef = tokensDef.apiToken;
  if (apiTokenDef) {
    Winbits.setCookie(apiTokenDef.cookieName, apiTokenDef.value, apiTokenDef.expireDays);
  } else {
    Winbits.deleteCookie(Winbits.apiTokenName);
  }
};

Winbits.expressLogin = function ($) {
  Winbits.checkRegisterConfirmation($);
  var apiToken = Winbits.getCookie(Winbits.apiTokenName);
  console.log(['API Token', apiToken]);
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
    console.log(['API token found as parameter, saving...', apiToken]);
    Winbits.saveApiToken(apiToken);
  }
};

Winbits.saveApiToken = function(apiToken) {
  Winbits.setCookie(Winbits.apiTokenName, apiToken, 7);
  console.log(['About to save API Token on Winbits', apiToken]);
  Winbits.proxy.post({ action: 'saveApiToken', params: [apiToken] });
//  Winbits.storeTokens(Winbits.jQuery);
};

Winbits.expressFacebookLogin = function ($) {
  console.log('Trying to login with facebook');
  Winbits.proxy.post({ action: 'facebookStatus' });
};

Winbits.initWidgets = function ($) {
  Winbits.initLightbox($);
  Winbits.initControls($);
  Winbits.initRegisterWidget($);
  Winbits.initCompleteRegisterWidget($);
  Winbits.initLoginWidget($);
  Winbits.initMyAccountWidget($);
  Winbits.initLogout($);
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
  sendEmail('.btnSmall');
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
      var $fbHolder = $layer.find('.facebook-btn-holder');
      if ($fbHolder.length > 0) {
        var $fbIFrameHolder = Winbits.$widgetContainer.find('#winbits-iframe-holder');
        var offset = $fbHolder.offset();
        offset.top = offset.top + 20;
        $fbIFrameHolder.offset(offset).height($fbHolder.height()).width($fbHolder.width()).css('z-index', 10000);
      }
    },
    onCleanup: function() {
      $(this.href).find('form').each(function(i, form) {
        var $form = $(form);
        $form.find('.errors').html('');
        $form.validate().resetForm();
        form.reset();
      });
      var $fbIFrameHolder = Winbits.$widgetContainer.find('#winbits-iframe-holder');
      $fbIFrameHolder.offset({top: -1000});
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

Winbits.initCompleteRegisterWidget = function ($) {
  $('#complete-register-form').submit(function (e) {
    e.preventDefault();
    var $form = $(this);
    $form.validate({
      rules: {
        birthdate: {
          dateISO: true
        }
      }
    });
    var day = $form.find('#day-input').val();
    var month = $form.find('#month-input').val();
    var year = $form.find('#year-input').val();
    if (day || month || year) {
      $form.find('[name=birthdate]').val((year > 13 ? '19' : '20') + year + '-' + month + '-' + day);
    }
    var formData = { verticalId: Winbits.config.verticalId };
    formData = Winbits.Forms.serializeForm($, $form, formData);
    if (formData.location === $form.find('[name=location]').attr('placeholder')) {
      delete formData.location
    }
    if (formData.gender) {
      formData.gender = formData.gender === 'H' ? 'male' : 'female'
    }
    $.ajax(Winbits.config.apiUrl + '/affiliation/profile.json', {
      type: 'PUT',
      contentType: 'application/json',
      dataType: 'json',
      data: JSON.stringify(formData),
      context: $form,
      beforeSend: function () {
        return Winbits.validateForm(this);
      },
      headers: { 'Accept-Language': 'es', 'WB-Api-Token': Winbits.getCookie(Winbits.apiTokenName) },
      success: function (data) {
        console.log(['Profile updated', data.response]);
        Winbits.loadUserProfile($, data.response);
        $.fancybox.close();
      },
      error: function (xhr, textStatus, errorThrown) {
        var error = JSON.parse(xhr.responseText);
        alert('Error while updating profile');
      },
      complete: function () {
        console.log('Request Completed!');
      }
    });
  });
};

Winbits.loadUserProfile = function($, profile) {
  console.log(['Loading user profile', profile]);
  var me = profile.profile;
  Winbits.$widgetContainer.find('.wb-user-bits-balance').text(me.bitsBalance);
  var $myProfilePanel = Winbits.$widgetContainer.find('.miPerfil');
  var $myProfileForm = Winbits.$widgetContainer.find('.editMiPerfil');
  $myProfilePanel.find('.profile-full-name').text((me.name || '') + ' ' + (me.lastName || ''));
  $myProfileForm.find('[name=name]').val(me.name);
  $myProfileForm.find('[name=lastName]').val(me.lastName);
  $myProfilePanel.find('.profile-email').text(profile.email).attr('href', 'mailto:' + profile.email);
  if (me.birthdate) {
    $myProfilePanel.find('.profile-age').text(me.birthdate);
    $myProfileForm.find('.day-input').val(me.birthdate.substr(8, 2));
    $myProfileForm.find('.month-input').val(me.birthdate.substr(5, 2));
    $myProfileForm.find('.year-input').val(me.birthdate.substr(2, 2));
  }
  if (me.gender) {
    $myProfileForm.find('[name=gender].' + me.gender).attr('checked', 'checked');
  }
  $myProfilePanel.find('.profile-location').text(me.location ? 'Col.' + me.location : '');
  $myProfilePanel.find('.profile-zip-code').text(me.zipCode ? 'CP.' + me.zipCode : '');
  $myProfileForm.find('[name=zipCode]').val(me.zipCode);
  $myProfilePanel.find('.profile-phone').text(me.phone ? 'Tel.' + me.phone : '');
  $myProfileForm.find('[name=phone]').val(me.phone);

  var address = profile.mainShippingAddress;
  if (address) {
    var $myAddressPanel = Winbits.$widgetContainer.find('.miDireccion');
    $myAddressPanel.find('.address-street').text(address.street ? 'Col.' + address.street : '');
    $myAddressPanel.find('.address-location').text(address.location ? 'Col.' + address.location : '');
    $myAddressPanel.find('.address-state').text(address.zipCodeInfo.state ? 'Del.' + address.zipCodeInfo.state : '');
    $myAddressPanel.find('.address-zip-code').text(address.zipCodeInfo.zipCode ? 'CP.' + address.zipCodeInfo.zipCode : '');
    $myAddressPanel.find('.address-phone').text(address.phone ? 'Tel.' + address.phone : '');
  }

  var subscriptions = profile.subscriptions;
  if (subscriptions) {
    var $mySubscriptionsPanel = Winbits.$widgetContainer.find('.miSuscripcion');
    var $subscriptionsList = $mySubscriptionsPanel.find('.wb-subscriptions-list');
    var $subscriptionsChecklist = Winbits.$widgetContainer.find('.wb-subscriptions-checklist');
    $.each(subscriptions, function(i, subscription) {
      if (subscription.active) {
        $('<li>' + subscription.name + '<a href="#" class="editLink">edit</a></li>').appendTo($subscriptionsList);
      }
      var $verticalCheck = $('<input type="checkbox" class="checkbox"><label class="checkboxLabel"></label>');
      var $checkbox = $($verticalCheck[0]);
      $checkbox.attr('value', subscription.id);
      if (subscription.active) {
        $checkbox.attr('checked', 'checked');
      }
      $($verticalCheck[1]).text(subscription.name);
      $subscriptionsChecklist.append($verticalCheck);
      customCheckbox($checkbox);
    });
//    $mySubscriptionsPanel.find('.subscriptions-periodicity').text();
  }
};

Winbits.restoreCart = function($) {
  var vCart = Winbits.getCookie(Winbits.vcartTokenName);
  if (vCart && false) {
    Winbits.transferVirtualCart($, vCart);
  } else {
    Winbits.loadUserCart($);
  }
};

Winbits.transferVirtualCart = function($, virtualCart) {
  var formData = { virtualCartData: JSON.parse(virtualCart) };
  $.ajax(Winbits.config.apiUrl + '/orders/assign-virtual-cart.json', {
    type: 'POST',
    dataType: 'json',
    data: JSON.stringify(formData),
    headers: { 'Accept-Language': 'es', 'WB-Api-Token': Winbits.getCookie(Winbits.apiTokenName) },
    success: function (data) {
      console.log(['V: User cart', data.response]);
      Winbits.setCookie(Winbits.vcartTokenName, '[]', 7);
      Winbits.proxy.post({ action: 'storeVirtualCart', params: ['[]'] });
      Winbits.refreshCart($, data.response);
    },
    error: function (xhr, textStatus, errorThrown) {
      var error = JSON.parse(xhr.responseText);
      alert(error.message);
    },
    complete: function () {
      console.log('Request Completed!');
    }
  });
};

Winbits.loadUserCart= function($) {
  $.ajax(Winbits.config.apiUrl + '/orders/cart-items.json', {
    dataType: 'json',
    headers: { 'Accept-Language': 'es', 'WB-Api-Token': Winbits.getCookie(Winbits.apiTokenName) },
    success: function (data) {
      console.log(['V: User cart', data.response]);
      Winbits.refreshCart($, data.response);
    },
    error: function (xhr, textStatus, errorThrown) {
      var error = JSON.parse(xhr.responseText);
      alert(error.message);
    },
    complete: function () {
      console.log('Request Completed!');
    }
  });
};

Winbits.loadVirtualCart = function($) {
  $.ajax(Winbits.config.apiUrl + '/orders/virtual-cart-items.json', {
    dataType: 'json',
    headers: { 'Accept-Language': 'es', 'wb-vcart': Winbits.getCookie(Winbits.vcartTokenName) },
    success: function (data) {
      console.log(['V: User cart', data.response]);
      Winbits.refreshCart($, data.response);
    },
    error: function (xhr, textStatus, errorThrown) {
      var error = JSON.parse(xhr.responseText);
      alert(error.message);
    },
    complete: function () {
      console.log('Request Completed!');
    }
  });
};

Winbits.loadCompleteRegisterForm = function($, profile) {
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
  $('#login-form').submit(function (e) {
    e.preventDefault();
    var $form = $(this);
    var formData = { verticalId: Winbits.config.verticalId };
    formData = Winbits.Forms.serializeForm($, $form, formData);
    console.log(['Login Data', formData]);
    $.ajax(Winbits.config.apiUrl + '/affiliation/login.json', {
      type: 'POST',
      contentType: 'application/json',
      dataType: 'json',
      data: JSON.stringify(formData),
      xhrFields: { withCredentials: true },
      context: $form,
      beforeSend: function () {
        return Winbits.validateForm(this);
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

Winbits.initMyAccountWidget = function($) {
  $('#update-profile-form').submit(function (e) {
    e.preventDefault();
    var $form = $(this);
    $form.validate({
      rules: {
        birthdate: {
          dateISO: true
        }
      }
    });
    var day = $form.find('.day-input').val();
    var month = $form.find('.month-input').val();
    var year = $form.find('.year-input').val();
    if (day || month || year) {
      $form.find('[name=birthdate]').val((year > 13 ? '19' : '20') + year + '-' + month + '-' + day);
    }
    var formData = { verticalId: Winbits.config.verticalId };
    formData = Winbits.Forms.serializeForm($, $form, formData);
    if (formData.location === $form.find('[name=location]').attr('placeholder')) {
      delete formData.location
    }
    if (formData.gender) {
      formData.gender = formData.gender === 'H' ? 'male' : 'female'
    }
    $.ajax(Winbits.config.apiUrl + '/affiliation/profile.json', {
      type: 'PUT',
      contentType: 'application/json',
      dataType: 'json',
      data: JSON.stringify(formData),
      context: $form,
      beforeSend: function () {
        return Winbits.validateForm(this);
      },
      headers: { 'Accept-Language': 'es', 'WB-Api-Token': Winbits.getCookie(Winbits.apiTokenName) },
      success: function (data) {
        console.log(['Profile updated', data.response]);
        var $myAccountPanel = this.closest('.myProfile');
        Winbits.loadUserProfile($, profile);
        $myAccountPanel.find('.editMiPerfil').hide();
        $myAccountPanel.find('.miPerfil').show();
      },
      error: function (xhr, textStatus, errorThrown) {
        var error = JSON.parse(xhr.responseText);
        alert('Error while updating profile');
      },
      complete: function () {
        console.log('Request Completed!');
      }
    });
  });
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
    var $errorMessageHolder = $('<p>' + error.meta.message + '. <span class="link-holder"></span></p>');
    $errorMessageHolder.find('.link-holder').append($resendConfirmLink);
    var message = error.message || error.meta.message;
    var $errors = $form.find('.errors');
    $errors.children().remove();
    $errors.append($errorMessageHolder);
  } else {
    var message = error.message || error.meta.message;
    $form.find('.errors').html('<p>' + message + '</p>');
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
  Winbits.Flags.loggedIn = true;
  Winbits.checkCompleteRegistration($);
  console.log('Logged In');
  Winbits.saveApiToken(profile.apiToken);
  Winbits.restoreCart($);
  Winbits.$widgetContainer.find('div.login').hide();
  Winbits.$widgetContainer.find('div.miCuentaPanel').show();
  Winbits.loadUserProfile($, profile);
};

Winbits.checkCompleteRegistration = function ($) {
  var params = Winbits.getUrlParams();
  var registerConfirmation = params._wb_register_confirm;
  if (registerConfirmation) {
    Winbits.showCompleteRegistrationLayer($);
  }
};

Winbits.showCompleteRegistrationLayer = function ($, profile) {
  $.fancybox.close();
  Winbits.loadCompleteRegisterForm($, profile);
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
  Winbits.proxy.post({ action: 'logout', params: [Winbits.Flags.fbConnect] });
  Winbits.deleteCookie(Winbits.apiTokenName);
  Winbits.$widgetContainer.find('div.miCuentaPanel').hide();
  Winbits.$widgetContainer.find('div.login').show();
  Winbits.resetMyAccountPanel($);
  Winbits.Flags.loggedIn = false;
  Winbits.Flags.fbConnect = false;
};

Winbits.resetMyAccountPanel = function($) {
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
  var birthday = myBirthdayDate.getFullYear() + "-" + myBirthdayDate.getMonth() + "-" + myBirthdayDate.getDate();
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
        Winbits.showCompleteRegistrationLayer($, data.response.profile);
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
      Winbits.Flags.fbConnect = true;
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
    } else {
      Winbits.loadVirtualCart(Winbits.jQuery);
    }
  },
  facebookLoginHandler: function (response) {
    console.log(['Facebook Login', response]);
    if (response.authResponse) {
      console.log('Requesting facebook profile...');
      Winbits.proxy.post({ action: 'facebookMe' });
    } else {
      console.log('Facebook login failed!');
    }
  },
  facebookMeHandler: function (response) {
    console.log(['Response from winbits-facebook me', response]);
    if (response.email) {
      console.log('Trying to log with facebook');
      Winbits.loginFacebook(response);
    }
  }
};

Winbits.EventHandlers = {
  clickDeleteCartDetailLink: function(e) {
    var $cartDetail = Winbits.jQuery(e.target).closest('li');
    if (Winbits.Flags.loggedIn) {
      Winbits.deleteUserCartDetail($cartDetail);
    } else {
      Winbits.deleteVirtualCartDetail($cartDetail);
    }
  }
};

Winbits.addToCart = function(cartItem) {
  if (!cartItem) {
    alert('Please specify a cart item object: {id: 1, quantity: 1}');
  }
  if (!cartItem.id) {
    alert('Id required! Please specify a cart item object: {id: 1, quantity: 1}');
  }
  if (!cartItem.quantity || cartItem.quantity < 1) {
    console.log('Setting default quantity (1)...')
    cartItem.quantity = 1;
  }
  var $cartDetail = Winbits.$widgetContainer.find('.cart-details-list').children('[data-id=' + cartItem.id + ']');
  if ($cartDetail.length === 0) {
    if (Winbits.Flags.loggedIn) {
      Winbits.addToUserCart(cartItem.id, cartItem.quantity, cartItem.bits);
    } else {
      Winbits.addToVirtualCart(cartItem.id, cartItem.quantity);
    }
  } else {
    var qty = cartItem.quantity + parseInt($cartDetail.find('.cart-detail-quantity').val());
    Winbits.updateCartDetail($cartDetail, qty, cartItem.bits);
  }
};

Winbits.addToUserCart = function(id, quantity, bits) {
  console.log('Adding to user cart...');
  var $ = Winbits.jQuery;
  var formData = {skuProfileId: id, quantity: quantity, bits: bits};
  $.ajax(Winbits.config.apiUrl + '/orders/cart-items.json', {
    type: 'POST',
    contentType: 'application/json',
    dataType: 'json',
    data: JSON.stringify(formData),
    headers: { 'Accept-Language': 'es', 'WB-Api-Token': Winbits.getCookie(Winbits.apiTokenName) },
    success: function (data) {
      console.log(['V: User cart', data.response]);
      Winbits.refreshCart($, data.response);
    },
    error: function (xhr, textStatus, errorThrown) {
      var error = JSON.parse(xhr.responseText);
      alert(error.meta.message);
    },
    complete: function () {
      console.log('Request Completed!');
    }
  });
};

Winbits.storeVirtualCart = function($, cart) {
  console.log(['Storing virtual cart...', cart]);
  var vCart = [];
  $.each(cart.cartDetails, function(i, cartDetail) {
    var vCartDetail = {};
    vCartDetail[cartDetail.skuProfile.id] = cartDetail.quantity;
    vCart.push(vCartDetail);
  });
  var vCartToken = JSON.stringify(vCart);
  console.log(['vCartToken', vCartToken]);
  Winbits.setCookie(Winbits.vcartTokenName, vCartToken, 7);
  Winbits.proxy.post({ action: 'storeVirtualCart', params: [vCartToken] });
};

Winbits.refreshCart = function($, cart) {
  console.log(['Refreshing cart...', cart]);
  var $cartHolder = Winbits.$widgetContainer.find('.cart-holder:visible');
  $cartHolder.find('.cart-items-count').text(cart.itemsCount);
  var $cartInfo = $cartHolder.find('.cart-info');
  $cartInfo.find('.cart-shipping-total').text(cart.shippingTotal || 'GRATIS');
  var cartTotal = cart.itemsTotal + cart.shippingTotal - (cart.bitsTotal || 0);
  $cartInfo.find('.cart-total').text('$' + cartTotal);
  $cartInfo.find('.cart-bits-total').text(cart.bitsTotal);
  var cartSaving = 0;
  $cartInfo.find('.cart-saving').text(cartSaving + '%');
  var $cartDetailsList = $cartHolder.find('.cart-details-list').html('');
  $.each(cart.cartDetails || [], function(i, cartDetail) {
    Winbits.addCartDetailInto($, cartDetail, $cartDetailsList);
  });
};

Winbits.addCartDetailInto = function($, cartDetail, cartDetailsList) {
  console.log(['Adding cart detail...', cartDetail]);
  var $cartDetailsList = Winbits.$(cartDetailsList);
  var $cartDetail = $('<li>' +
      '<a href="#"><img class="cart-detail-thumb"></a>' +
      '<p class="descriptionItem cart-detail-name"></p>' +
      '<label>Cantidad</label>' +
      '<input type="text" class="inputStepper cart-detail-quantity">' +
      '<p class="priceItem cart-detail-price"></p>' +
      '<span class="verticalName">Producto de <em class="cart-detail-vertical"></em></span>' +
      '<span class="deleteItem"><a href="#" class="cart-detail-delete-link">eliminar</a></span>' +
      '</li>');
  $cartDetail.attr('data-id', cartDetail.skuProfile.id);
  $cartDetail.find('.cart-detail-thumb').attr('src', cartDetail.skuProfile.item.thumbnail).attr('alt', '[thumbnail]');
  $cartDetail.find('.cart-detail-name').text(cartDetail.skuProfile.item.name);
  customStepper($cartDetail.find('.cart-detail-quantity').val(cartDetail.quantity)).on('step', function(e, previous) {
    var $cartDetailStepper = $(this);
    var val = parseInt($cartDetailStepper.val());
    if (previous != val) {
      console.log(['previous', 'current', previous, val]);
      Winbits.updateCartDetail($cartDetailStepper.closest('li'), val);
    }
  });
  $cartDetail.find('.cart-detail-price').text('$' + cartDetail.skuProfile.price);
  $cartDetail.find('.cart-detail-vertical').text(cartDetail.skuProfile.item.vertical.name);
  $cartDetail.find('.cart-detail-delete-link').click(Winbits.EventHandlers.clickDeleteCartDetailLink);
  $cartDetail.appendTo($cartDetailsList);
};

Winbits.updateCartDetail = function(cartDetail, quantity, bits) {
  var $cartDetail = Winbits.$(cartDetail);
  if (Winbits.Flags.loggedIn) {
    Winbits.updateUserCartDetail($cartDetail, quantity, bits);
  } else {
    Winbits.updateVirtualCartDetail($cartDetail, quantity);
  }
};

Winbits.updateUserCartDetail = function(cartDetail, quantity, bits) {
  console.log(['Updating cart detail...', cartDetail]);
  var $cartDetail = Winbits.$(cartDetail);
  var $ = Winbits.jQuery;
  var formData = {
    quantity: quantity,
    bits: bits || 0
  };
  var id = $cartDetail.attr('data-id');
  $.ajax(Winbits.config.apiUrl + '/orders/cart-items/' + id + '.json', {
    type: 'PUT',
    contentType: 'application/json',
    dataType: 'json',
    data: JSON.stringify(formData),
    headers: { 'Accept-Language': 'es', 'WB-Api-Token': Winbits.getCookie(Winbits.apiTokenName) },
    success: function (data) {
      console.log(['V: User cart', data.response]);
      Winbits.refreshCart($, data.response);
    },
    error: function (xhr, textStatus, errorThrown) {
      var error = JSON.parse(xhr.responseText);
      alert(error.meta.message);
    },
    complete: function () {
      console.log('Request Completed!');
    }
  });
};

Winbits.deleteUserCartDetail = function(cartDetail) {
  console.log(['Deleting user cart detail...', cartDetail]);
  var $ = Winbits.jQuery;
  var $cartDetail = Winbits.$(cartDetail);
  var id = $cartDetail.attr('data-id');
  $.ajax(Winbits.config.apiUrl + '/orders/cart-items/' + id + '.json', {
    type: 'DELETE',
    dataType: 'json',
    headers: { 'Accept-Language': 'es', 'WB-Api-Token': Winbits.getCookie(Winbits.apiTokenName) },
    success: function (data) {
      console.log(['V: User cart', data.response]);
      Winbits.refreshCart($, data.response);
    },
    error: function (xhr, textStatus, errorThrown) {
      var error = JSON.parse(xhr.responseText);
      alert(error.meta.message);
    },
    complete: function () {
      console.log('Request Completed!');
    }
  });
};

Winbits.addToVirtualCart = function(id, quantity) {
  console.log('Adding to virtual cart...');
  var $ = Winbits.jQuery;
  var formData = {skuProfileId: id, quantity: quantity, bits: 0};
  $.ajax(Winbits.config.apiUrl + '/orders/virtual-cart-items.json', {
    type: 'POST',
    contentType: 'application/json',
    dataType: 'json',
    data: JSON.stringify(formData),
    headers: { 'Accept-Language': 'es', 'wb-vcart': Winbits.getCookie(Winbits.vcartTokenName) },
    success: function (data) {
      console.log(['V: Virtual cart', data.response]);
      Winbits.storeVirtualCart($, data.response);
      Winbits.refreshCart($, data.response);
    },
    error: function (xhr, textStatus, errorThrown) {
      var error = JSON.parse(xhr.responseText);
      console.log(error.meta.message);
    },
    complete: function () {
      console.log('Request Completed!');
    }
  });
};

Winbits.updateVirtualCartDetail = function(cartDetail, quantity) {
  console.log(['Updating cart detail...', cartDetail]);
  var $cartDetail = Winbits.$(cartDetail);
  var $ = Winbits.jQuery;
  var formData = {
    quantity: quantity
  };
  var id = $cartDetail.attr('data-id');
  $.ajax(Winbits.config.apiUrl + '/orders/virtual-cart-items/' + id + '.json', {
    type: 'PUT',
    contentType: 'application/json',
    dataType: 'json',
    data: JSON.stringify(formData),
    headers: { 'Accept-Language': 'es', 'wb-vcart': Winbits.getCookie(Winbits.vcartTokenName) },
    success: function (data) {
      console.log(['V: Virtual cart', data.response]);
      Winbits.storeVirtualCart($, data.response);
      Winbits.refreshCart($, data.response);
    },
    error: function (xhr, textStatus, errorThrown) {
      var error = JSON.parse(xhr.responseText);
      console.log(error.meta.message);
    },
    complete: function () {
      console.log('Request Completed!');
    }
  });
};

Winbits.deleteVirtualCartDetail = function(cartDetail) {
  console.log(['Deleting virtual cart detail...', cartDetail]);
  var $ = Winbits.jQuery;
  var $cartDetail = Winbits.$(cartDetail);
  var id = $cartDetail.attr('data-id');
  $.ajax(Winbits.config.apiUrl + '/orders/virtual-cart-items/' + id + '.json', {
    type: 'DELETE',
    dataType: 'json',
    headers: { 'Accept-Language': 'es', 'wb-vcart': Winbits.getCookie(Winbits.vcartTokenName) },
    success: function (data) {
      console.log(['V: User cart', data.response]);
      Winbits.storeVirtualCart($, data.response);
      Winbits.refreshCart($, data.response);
    },
    error: function (xhr, textStatus, errorThrown) {
      var error = JSON.parse(xhr.responseText);
      console.log(error.meta.message);
    },
    complete: function () {
      console.log('Request Completed!');
    }
  });
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
        Winbits.$widgetContainer.append('<script type="text/javascript" src="' + Winbits.config.baseUrl  + '/include/js/extra.js"></script>" ');
        Winbits.initProxy($);
      });
    }
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

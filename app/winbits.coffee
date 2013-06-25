#var console = window.console || {};
#console.log = console.log || function () {};
Winbits = Winbits or {}
Winbits.extraScriptLoaded = false
Winbits.facebookLoaded = false
Winbits.config =  require('./config')
console.log Winbits.config

Winbits.apiTokenName = "_wb_api_token"
Winbits.vcartTokenName = "_wb_vcart_token"
Winbits.Flags =
  loggedIn: false
  fbConnect: false

Winbits.$ = (element) ->
  (if element instanceof Winbits.jQuery then element else Winbits.jQuery(element))

Winbits.setCookie = setCookie = (c_name, value, exdays) ->
  exdays = exdays or 7
  exdate = new Date()
  exdate.setDate exdate.getDate() + exdays
  c_value = escape(value) + ((if (exdays is null) then "" else "; path=/; expires=" + exdate.toUTCString()))
  document.cookie = c_name + "=" + c_value

Winbits.getCookie = getCookie = (c_name) ->
  c_value = document.cookie
  c_start = c_value.indexOf(" " + c_name + "=")
  c_start = c_value.indexOf(c_name + "=")  if c_start is -1
  if c_start is -1
    c_value = null
  else
    c_start = c_value.indexOf("=", c_start) + 1
    c_end = c_value.indexOf(";", c_start)
    c_end = c_value.length  if c_end is -1
    c_value = unescape(c_value.substring(c_start, c_end))
  c_value

Winbits.deleteCookie = (name) ->
  document.cookie = name + "=; path=/; expires=Thu, 01 Jan 1970 00:00:01 GMT"

Winbits.getUrlParams = ->
  vars = []
  hash = undefined
  hashes = window.location.href.slice(window.location.href.indexOf("?") + 1).split("&")
  i = 0

  while i < hashes.length
    hash = hashes[i].split("=")
    vars.push hash[0]
    vars[hash[0]] = hash[1]
    i++
  vars

Winbits.waitForFacebook = (f, $) ->
  console.log ["Winbits.facebookLoaded", Winbits.facebookLoaded]
  if Winbits.facebookLoaded
    f $
  else
    setTimeout (->
      Winbits.waitForFacebook f, $
    ), 10

Winbits.init = ->
  console.log "was here"
  $ = Winbits.jQuery
  $(".wb-vertical-" + Winbits.config.verticalId).addClass "current"
  Winbits.requestTokens $
  Winbits.initWidgets $
  Winbits.alertErrors $

Winbits.initProxy = ($) ->
  iframeSrc = Winbits.config.baseUrl + "/winbits.html?origin=" + Winbits.config.proxyUrl
  iframeStyle = "width:100%;border: 0px;overflow: hidden;"
  $iframe = $("<iframe id=\"winbits-iframe\" name=\"winbits-iframe\" height=\"30\" style=\"" + iframeStyle + "\" src=\"" + iframeSrc + "\"></iframe>").on("load", ->
    unless Winbits.initialized
      Winbits.initialized = true
      Winbits.init()
  )
  Winbits.$widgetContainer.find("#winbits-iframe-holder").append $iframe

  # Create a proxy window to send to and receive
  # messages from the iFrame
  Winbits.proxy = new Porthole.WindowProxy(Winbits.config.baseUrl + "/proxy.html", "winbits-iframe")

  # Register an event handler to receive messages;
  Winbits.proxy.addEventListener (messageEvent) ->
    console.log ["Message from Winbits", messageEvent]
    data = messageEvent.data
    handlerFn = Winbits.Handlers[data.action + "Handler"]
    if handlerFn
      handlerFn.apply this, data.params
    else
      console.log "Invalid action from Winbits"


Winbits.alertErrors = ($) ->
  params = Winbits.getUrlParams()
  alert params._wb_error  if params._wb_error

Winbits.requestTokens = ($) ->
  console.log "Requesting tokens"
  Winbits.proxy.post action: "getTokens"

Winbits.segregateTokens = ($, tokensDef) ->
  console.log ["tokensDef", tokensDef]
  vcartTokenDef = tokensDef.vcartToken
  Winbits.setCookie vcartTokenDef.cookieName, vcartTokenDef.value, vcartTokenDef.expireDays
  apiTokenDef = tokensDef.apiToken
  if apiTokenDef
    Winbits.setCookie apiTokenDef.cookieName, apiTokenDef.value, apiTokenDef.expireDays
  else
    Winbits.deleteCookie Winbits.apiTokenName

Winbits.expressLogin = ($) ->
  Winbits.checkRegisterConfirmation $
  apiToken = Winbits.getCookie(Winbits.apiTokenName)
  console.log ["API Token", apiToken]
  if apiToken
    $.ajax Winbits.config.apiUrl + "/affiliation/express-login.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(apiToken: apiToken)
      headers:
        "Accept-Language": "es"

      xhrFields:
        withCredentials: true

      context: $
      success: (data) ->
        console.log "express-login.json Success!"
        console.log ["data", data]
        Winbits.applyLogin $, data.response

      error: (xhr, textStatus, errorThrown) ->
        console.log "express-login.json Error!"
        error = JSON.parse(xhr.responseText)
        alert error.meta.message

  else
    Winbits.expressFacebookLogin $

Winbits.checkRegisterConfirmation = ($) ->
  params = Winbits.getUrlParams()
  apiToken = params._wb_api_token
  if apiToken
    console.log ["API token found as parameter, saving...", apiToken]
    Winbits.saveApiToken apiToken

Winbits.saveApiToken = (apiToken) ->
  Winbits.setCookie Winbits.apiTokenName, apiToken, 7
  console.log ["About to save API Token on Winbits", apiToken]
  Winbits.proxy.post
    action: "saveApiToken"
    params: [apiToken]



#  Winbits.storeTokens(Winbits.jQuery);
Winbits.expressFacebookLogin = ($) ->
  console.log "Trying to login with facebook"
  Winbits.proxy.post action: "facebookStatus"

Winbits.initWidgets = ($) ->
  Winbits.initLightbox $
  Winbits.initControls $
  Winbits.initRegisterWidget $
  Winbits.initCompleteRegisterWidget $
  Winbits.initLoginWidget $
  Winbits.initMyAccountWidget $
  Winbits.initLogout $

Winbits.initControls = ($) ->
  Winbits.$widgetContainer.find(":input[placeholder]").placeholder()
  Winbits.$widgetContainer.find("form").validate()

  #  var $form = Winbits.$widgetContainer.find('#wb-change-password-form');
  #  $form.find('.editBtn').click(function(e) {
  #    if (!Winbits.$widgetContainer.find('#wb-change-password-form').valid()) {
  #      e.stopImmediatePropagation();
  #    };
  #  });
  changeShippingAddress
    obj: ".shippingAddresses"
    objetivo: ".shippingItem"
    activo: "shippingSelected"
    inputradio: ".shippingRadio"

  customCheckbox ".checkbox"
  customRadio ".divGender"
  customSelect ".select"
  customSlider ".slideInput"
  customStepper ".inputStepper"
  dropMenu
    obj: ".miCuentaDiv"
    clase: ".dropMenu"
    trigger: ".triggerMiCuenta"
    other: ".miCarritoDiv"

  dropMenu
    obj: ".miCarritoDiv"
    clase: ".dropMenu"
    trigger: ".shopCarMin"
    other: ".miCuentaDiv"

  openFolder
    obj: ".knowMoreMin"
    trigger: ".knowMoreMin .openClose"
    objetivo: ".knowMoreMax"

  openFolder
    obj: ".knowMoreMax"
    trigger: ".knowMoreMax .openClose"
    objetivo: ".knowMoreMin"

  openFolder
    obj: ".myProfile .miPerfil"
    trigger: ".myProfile .miPerfil .editBtn"
    objetivo: ".myProfile .editMiPerfil"

  openFolder
    obj: ".myProfile .editMiPerfil"
    trigger: ".myProfile .editMiPerfil .editBtn"
    objetivo: ".myProfile .miPerfil"

  openFolder
    obj: ".myProfile .miPerfil"
    trigger: ".myProfile .miPerfil .changePassBtn"
    objetivo: ".myProfile .changePassDiv"

  openFolder
    obj: ".myProfile .changePassDiv"
    trigger: ".myProfile .changePassDiv .editBtn"
    objetivo: ".myProfile .miPerfil"

  openFolder
    obj: ".myAddress .miDireccion"
    trigger: ".myAddress .miDireccion .editBtn, .myAddress .miDireccion .changeAddressBtn"
    objetivo: ".myAddress .editMiDireccion"

  openFolder
    obj: ".myAddress .editMiDireccion"
    trigger: ".myAddress .editMiDireccion .editBtn"
    objetivo: ".myAddress .miDireccion"

  openFolder
    obj: ".mySuscription .miSuscripcion"
    trigger: ".mySuscription .miSuscripcion .editBtn, .mySuscription .miSuscripcion .editLink"
    objetivo: ".mySuscription .editSuscription"

  openFolder
    obj: ".mySuscription .editSuscription"
    trigger: ".mySuscription .editSuscription .editBtn"
    objetivo: ".mySuscription .miSuscripcion"

  openFolder
    obj: ".shippingAddresses"
    trigger: ".shippingAdd"
    objetivo: ".shippingNewAddress"

  openFolder
    obj: ".shippingNewAddress"
    trigger: ".submitButton .btnCancel"
    objetivo: ".shippingAddresses"

  sendEmail ".btnSmall"
  verticalCarousel ".carritoDivLeft .carritoContainer"
  console.log "Winibits Initialized"

Winbits.initLightbox = ($) ->
  Winbits.$widgetContainer.find("a.fancybox").fancybox
    overlayShow: true
    hideOnOverlayClick: true
    enableEscapeButton: true
    showCloseButton: true
    overlayOpacity: 0.9
    overlayColor: "#333"
    padding: 0
    type: "inline"
    onComplete: ->
      $layer = $(@href)
      $layer.find("form").first().find("input.default").focus()
      $fbHolder = $layer.find(".facebook-btn-holder")
      if $fbHolder.length > 0
        $fbIFrameHolder = Winbits.$widgetContainer.find("#winbits-iframe-holder")
        offset = $fbHolder.offset()
        offset.top = offset.top + 20
        $fbIFrameHolder.offset(offset).height($fbHolder.height()).width($fbHolder.width()).css "z-index", 10000

    onCleanup: ->
      $(@href).find("form").each (i, form) ->
        $form = $(form)
        $form.find(".errors").html ""
        $form.validate().resetForm()
        form.reset()

      $fbIFrameHolder = Winbits.$widgetContainer.find("#winbits-iframe-holder")
      $fbIFrameHolder.offset top: -1000


Winbits.initRegisterWidget = ($) ->
  $("#winbits-register-form").submit (e) ->
    e.preventDefault()
    $form = $(this)
    formData = verticalId: Winbits.config.verticalId
    formData = Winbits.Forms.serializeForm($, $form, formData)
    $.ajax Winbits.config.apiUrl + "/affiliation/register.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      context: $form
      beforeSend: ->
        Winbits.validateForm this

      headers:
        "Accept-Language": "es"

      success: (data) ->
        console.log "Request Success!"
        console.log ["data", data]
        $.fancybox.close()
        Winbits.showRegisterConfirmation $  unless data.response.active

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        Winbits.renderRegisterFormErrors this, error

      complete: ->
        console.log "Request Completed!"



Winbits.validateForm = (form) ->
  $form = Winbits.$(form)
  $form.find(".errors").html ""
  $form.valid()

Winbits.renderRegisterFormErrors = (form, error) ->
  $form = Winbits.$(form)
  code = error.code or error.meta.code
  if code is "AFER001"
    message = error.message or error.meta.message
    $form.find(".errors").html "<p>" + message + "</p>"

Winbits.showRegisterConfirmation = ($) ->
  setTimeout (->
    $("a[href=#register-confirm-layer]").click()
  ), 1000

Winbits.initCompleteRegisterWidget = ($) ->
  $("#complete-register-form").submit (e) ->
    e.preventDefault()
    $form = $(this)
    $form.validate rules:
      birthdate:
        dateISO: true

    day = $form.find(".day-input").val()
    month = $form.find(".month-input").val()
    year = $form.find(".year-input").val()
    if day and month and year
      year = ((if year > 13 then "19" else "20")) + year
      $form.find("[name=birthdate]").val year + "-" + month + "-" + day
    formData = verticalId: Winbits.config.verticalId
    formData = Winbits.Forms.serializeForm($, $form, formData)
    delete formData.location  if formData.location is $form.find("[name=location]").attr("placeholder")
    formData.gender = (if formData.gender is "H" then "male" else "female")  if formData.gender
    $.ajax Winbits.config.apiUrl + "/affiliation/profile.json",
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      context: $form
      beforeSend: ->
        Winbits.validateForm this

      headers:
        "Accept-Language": "es"
        "WB-Api-Token": Winbits.getCookie(Winbits.apiTokenName)

      success: (data) ->
        console.log ["Profile updated", data.response]
        Winbits.loadUserProfile $, data.response
        $.fancybox.close()

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert "Error while updating profile"

      complete: ->
        console.log "Request Completed!"



Winbits.loadUserProfile = ($, profile) ->
  console.log ["Loading user profile", profile]
  me = profile.profile
  Winbits.$widgetContainer.find(".wb-user-bits-balance").text me.bitsBalance
  $myProfilePanel = Winbits.$widgetContainer.find(".miPerfil")
  $myProfileForm = Winbits.$widgetContainer.find(".editMiPerfil")
  $myProfilePanel.find(".profile-full-name").text (me.name or "") + " " + (me.lastName or "")
  $myProfileForm.find("[name=name]").val me.name
  $myProfileForm.find("[name=lastName]").val me.lastName
  $myProfilePanel.find(".profile-email").text(profile.email).attr "href", "mailto:" + profile.email
  if me.birthdate
    $myProfilePanel.find(".profile-age").text me.birthdate
    $myProfileForm.find(".day-input").val me.birthdate.substr(8, 2)
    $myProfileForm.find(".month-input").val me.birthdate.substr(5, 2)
    $myProfileForm.find(".year-input").val me.birthdate.substr(2, 2)
  $myProfileForm.find("[name=gender]." + me.gender).attr("checked", "checked").next().addClass "spanSelected"  if me.gender
  $myProfilePanel.find(".profile-location").text (if me.location then "Col." + me.location else "")
  $myProfilePanel.find(".profile-zip-code").text (if me.zipCode then "CP." + me.zipCode else "")
  $myProfileForm.find("[name=zipCode]").val me.zipCode
  $myProfilePanel.find(".profile-phone").text (if me.phone then "Tel." + me.phone else "")
  $myProfileForm.find("[name=phone]").val me.phone
  address = profile.mainShippingAddress
  if address
    $myAddressPanel = Winbits.$widgetContainer.find(".miDireccion")
    $myAddressPanel.find(".address-street").text (if address.street then "Col." + address.street else "")
    $myAddressPanel.find(".address-location").text (if address.location then "Col." + address.location else "")
    $myAddressPanel.find(".address-state").text (if address.zipCodeInfo.state then "Del." + address.zipCodeInfo.state else "")
    $myAddressPanel.find(".address-zip-code").text (if address.zipCodeInfo.zipCode then "CP." + address.zipCodeInfo.zipCode else "")
    $myAddressPanel.find(".address-phone").text (if address.phone then "Tel." + address.phone else "")
  subscriptions = profile.subscriptions
  if subscriptions
    $mySubscriptionsPanel = Winbits.$widgetContainer.find(".miSuscripcion")
    $subscriptionsList = $mySubscriptionsPanel.find(".wb-subscriptions-list")
    $subscriptionsChecklist = Winbits.$widgetContainer.find(".wb-subscriptions-checklist")
    $.each subscriptions, (i, subscription) ->
      $("<li>" + subscription.name + "<a href=\"#\" class=\"editLink\">edit</a></li>").appendTo $subscriptionsList  if subscription.active
      $verticalCheck = $("<input type=\"checkbox\" class=\"checkbox\"><label class=\"checkboxLabel\"></label>")
      $checkbox = $($verticalCheck[0])
      $checkbox.attr "value", subscription.id
      $checkbox.attr "checked", "checked"  if subscription.active
      $($verticalCheck[1]).text subscription.name
      $subscriptionsChecklist.append $verticalCheck
      customCheckbox $checkbox



#    $mySubscriptionsPanel.find('.subscriptions-periodicity').text();
Winbits.restoreCart = ($) ->
  vCart = Winbits.getCookie(Winbits.vcartTokenName)
  unless vCart is "[]"
    Winbits.transferVirtualCart $, vCart
  else
    Winbits.loadUserCart $

Winbits.transferVirtualCart = ($, virtualCart) ->
  formData = virtualCartData: JSON.parse(virtualCart)
  $.ajax Winbits.config.apiUrl + "/orders/assign-virtual-cart.json",
    type: "POST"
    contentType: "application/json"
    dataType: "json"
    data: JSON.stringify(formData)
    headers:
      "Accept-Language": "es"
      "WB-Api-Token": Winbits.getCookie(Winbits.apiTokenName)

    success: (data) ->
      console.log ["V: User cart", data.response]
      Winbits.setCookie Winbits.vcartTokenName, "[]", 7
      Winbits.proxy.post
        action: "storeVirtualCart"
        params: ["[]"]

      Winbits.refreshCart $, data.response

    error: (xhr, textStatus, errorThrown) ->
      error = JSON.parse(xhr.responseText)
      alert error.message

    complete: ->
      console.log "Request Completed!"


Winbits.loadUserCart = ($) ->
  $.ajax Winbits.config.apiUrl + "/orders/cart-items.json",
    dataType: "json"
    headers:
      "Accept-Language": "es"
      "WB-Api-Token": Winbits.getCookie(Winbits.apiTokenName)

    success: (data) ->
      console.log ["V: User cart", data.response]
      Winbits.refreshCart $, data.response

    error: (xhr, textStatus, errorThrown) ->
      error = JSON.parse(xhr.responseText)
      alert error.message

    complete: ->
      console.log "Request Completed!"


Winbits.loadVirtualCart = ($) ->
  $.ajax Winbits.config.apiUrl + "/orders/virtual-cart-items.json",
    dataType: "json"
    headers:
      "Accept-Language": "es"
      "wb-vcart": Winbits.getCookie(Winbits.vcartTokenName)

    success: (data) ->
      console.log ["V: User cart", data.response]
      Winbits.refreshCart $, data.response

    error: (xhr, textStatus, errorThrown) ->
      error = JSON.parse(xhr.responseText)
      alert error.message

    complete: ->
      console.log "Request Completed!"


Winbits.loadCompleteRegisterForm = ($, profile) ->
  console.log ["Loading profile", profile]
  if profile
    $profileForm = Winbits.$widgetContainer.find("form#complete-register-form")
    $profileForm.find("input[name=name]").val profile.name
    $profileForm.find("input[name=lastName]").val profile.lastName
    if profile.birthdate
      birthday = profile.birthdate.split("-")
      year = birthday[0]
      year = (if year.length > 2 then year.substr(2) else year)
      $profileForm.find("input.day-input").val birthday[2]
      $profileForm.find("input.month-input").val birthday[1]
      $profileForm.find("input.year-input").val year
      $profileForm.find("input[name=birthdate]").val profile.birthdate
    $profileForm.find("input[name=gender]." + profile.gender).attr("checked", "checked").next().addClass "spanSelected"  if profile.gender

Winbits.initLoginWidget = ($) ->
  Winbits.$widgetContainer.find("#login-form").submit (e) ->
    e.preventDefault()
    $form = $(this)
    formData = verticalId: Winbits.config.verticalId
    formData = Winbits.Forms.serializeForm($, $form, formData)
    console.log ["Login Data", formData]
    $.ajax Winbits.config.apiUrl + "/affiliation/login.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      xhrFields:
        withCredentials: true

      context: $form
      beforeSend: ->
        Winbits.validateForm this

      headers:
        "Accept-Language": "es"

      success: (data) ->
        console.log "Request Success!"
        console.log ["data", data]
        Winbits.applyLogin $, data.response
        $.fancybox.close()

      error: (xhr, textStatus, errorThrown) ->
        console.log xhr
        error = JSON.parse(xhr.responseText)
        Winbits.renderLoginFormErrors this, error

      complete: ->
        console.log "Request Completed!"



Winbits.initMyAccountWidget = ($) ->
  Winbits.$widgetContainer.find("#update-profile-form").submit (e) ->
    e.preventDefault()
    $form = $(this)
    $form.validate rules:
      birthdate:
        dateISO: true

    day = $form.find(".day-input").val()
    month = $form.find(".month-input").val()
    year = $form.find(".year-input").val()
    if day and month and year
      year = ((if year > 13 then "19" else "20")) + year
      $form.find("[name=birthdate]").val year + "-" + month + "-" + day
    formData = verticalId: Winbits.config.verticalId
    formData = Winbits.Forms.serializeForm($, $form, formData)
    delete formData.location  if formData.location is $form.find("[name=location]").attr("placeholder")
    formData.gender = (if formData.gender is "H" then "male" else "female")  if formData.gender
    $.ajax Winbits.config.apiUrl + "/affiliation/profile.json",
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      context: $form
      beforeSend: ->
        Winbits.validateForm this

      headers:
        "Accept-Language": "es"
        "WB-Api-Token": Winbits.getCookie(Winbits.apiTokenName)

      success: (data) ->
        console.log ["Profile updated", data.response]
        $myAccountPanel = @closest(".myProfile")
        Winbits.loadUserProfile $, data.response
        $myAccountPanel.find(".editMiPerfil").hide()
        $myAccountPanel.find(".miPerfil").show()

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert "Error while updating profile"

      complete: ->
        console.log "Request Completed!"


  Winbits.$widgetContainer.find("#wb-change-password-form").submit((e) ->
    e.preventDefault()
    $form = $(this)
    formData = verticalId: Winbits.config.verticalId
    formData = Winbits.Forms.serializeForm($, $form, formData)
    $.ajax Winbits.config.apiUrl + "/affiliation/change-password.json",
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      context: $form
      beforeSend: ->
        Winbits.validateForm this

      headers:
        "Accept-Language": "es"
        "WB-Api-Token": Winbits.getCookie(Winbits.apiTokenName)

      success: (data) ->
        console.log ["Password change", data.response]
        @find(".editBtn").click()
        @validate().resetForm()
        @get(0).reset()

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        @find(".errors").append "<p>El password ingresado no es el actual</p>"

      complete: ->
        console.log "Request Completed!"

  ).validate()

Winbits.renderLoginFormErrors = (form, error) ->
  $ = Winbits.jQuery
  $form = Winbits.$(form)
  if error.meta.code is "AFER004"
    $resendConfirmLink = $("<a href=\"" + error.response.resendConfirmUrl + "\">Reenviar correo de confirmaci&oacute;n</a>")
    $resendConfirmLink.click (e) ->
      e.preventDefault()
      Winbits.resendConfirmLink $, e.target

    $errorMessageHolder = $("<p>" + error.meta.message + ". <span class=\"link-holder\"></span></p>")
    $errorMessageHolder.find(".link-holder").append $resendConfirmLink
    message = error.message or error.meta.message
    $errors = $form.find(".errors")
    $errors.children().remove()
    $errors.append $errorMessageHolder
  else
    message = error.message or error.meta.message
    $form.find(".errors").html "<p>" + message + "</p>"

Winbits.resendConfirmLink = ($, link) ->
  $link = Winbits.$(link)
  url = $link.attr("href")
  $.ajax url,
    dataType: "json"
    headers:
      "Accept-Language": "es"

    success: (data) ->
      console.log "resendConfirm Success!"
      console.log ["data", data]
      Winbits.showRegisterConfirmation $

    error: (xhr, textStatus, errorThrown) ->
      error = JSON.parse(xhr.responseText)
      alert error.response.message

    complete: ->
      console.log "resendConfirm Completed!"


Winbits.applyLogin = ($, profile) ->
  Winbits.Flags.loggedIn = true
  Winbits.checkCompleteRegistration $
  console.log "Logged In"
  Winbits.saveApiToken profile.apiToken
  Winbits.restoreCart $
  Winbits.$widgetContainer.find("div.login").hide()
  Winbits.$widgetContainer.find("div.miCuentaPanel").show()
  Winbits.loadUserProfile $, profile

Winbits.checkCompleteRegistration = ($) ->
  params = Winbits.getUrlParams()
  registerConfirmation = params._wb_register_confirm
  Winbits.showCompleteRegistrationLayer $  if registerConfirmation

Winbits.showCompleteRegistrationLayer = ($, profile) ->
  $.fancybox.close()
  Winbits.loadCompleteRegisterForm $, profile
  $("a[href=#complete-register-layer]").click()

Winbits.initLogout = ($) ->
  $("#winbits-logout-link").click (e) ->
    e.preventDefault()
    $.ajax Winbits.config.apiUrl + "/affiliation/logout.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      xhrFields:
        withCredentials: true

      headers:
        "Accept-Language": "es"

      success: (data) ->
        console.log "logout.json Success!"
        Winbits.applyLogout $, data.response

      error: (xhr, textStatus, errorThrown) ->
        console.log "logout.json Error!"
        error = JSON.parse(xhr.responseText)
        alert error.meta.message

      complete: ->
        console.log "logout.json Completed!"



Winbits.applyLogout = ($, logoutData) ->
  Winbits.proxy.post
    action: "logout"
    params: [Winbits.Flags.fbConnect]

  Winbits.deleteCookie Winbits.apiTokenName
  Winbits.resetWidget $
  Winbits.Flags.loggedIn = false
  Winbits.Flags.fbConnect = false

Winbits.resetWidget = ($) ->
  Winbits.$widgetContainer.find("div.miCuentaPanel").hide()
  Winbits.$widgetContainer.find("div.login").show()
  $reseteables = Winbits.$widgetContainer.find(".reseteable").each((i, reseteable) ->
    $reseteable = $(reseteable)
    if $reseteable.is("[data-reset-val]")
      $reseteable.val $reseteable.attr("data-reset-val")
    else if $reseteable.is("[data-reset-text]")
      $reseteable.text $reseteable.attr("data-reset-text")
    else if $reseteable.is("[data-reset-unload]")
      $reseteable.html ""
    else
      $reseteable.val ""
  )

Winbits.Forms = Winbits.Forms or {}
Winbits.Forms.serializeForm = ($, form, context) ->
  formData = context or {}
  $form = Winbits.$(form)
  $.each $form.serializeArray(), (i, f) ->
    formData[f.name] = f.value

  formData

Winbits.loadFacebook = ->
  window.fbAsyncInit = ->
    FB.init
      appId: "486640894740634"
      status: true
      cookie: true
      xfbml: true

    console.log "FB.init called."
    Winbits.facebookLoaded = true

  (->
    e = document.createElement("script")
    e.async = true
    e.src = "http://connect.facebook.net/en_US/all.js"
    (document.getElementsByTagName("head")[0] or document.documentElement).appendChild e
  )()

Winbits.loginFacebookHandler = (response) ->
  console.log ["FB.login respose", response]
  if response.authResponse
    FB.api "/me", (me) ->
      console.log ["FB.me respose", me]
      Winbits.loginFacebook me  if me.email

  else
    console.log "User cancelled login or did not fully authorize."

Winbits.loginFacebook = (me) ->
  $ = Winbits.jQuery
  myBirthdayDate = new Date(me.birthday)
  birthday = myBirthdayDate.getFullYear() + "-" + (myBirthdayDate.getMonth() + 1) + "-" + myBirthdayDate.getDate()
  payLoad =
    name: me.first_name
    lastName: me.last_name
    email: me.email
    birthdate: birthday
    gender: me.gender
    verticalId: Winbits.config.verticalId
    locale: me.locale
    facebookId: me.id
    facebookToken: me.id

  $.fancybox.close()
  console.log "Enviando info al back"
  $.ajax Winbits.config.apiUrl + "/affiliation/facebook",
    type: "POST"
    contentType: "application/json"
    dataType: "json"
    data: JSON.stringify(payLoad)
    xhrFields:
      withCredentials: true

    headers:
      "Accept-Language": "es"

    success: (data) ->
      console.log "facebook.json success!"
      console.log ["data", data]
      Winbits.applyLogin $, data.response
      if 201 is data.meta.status
        console.log "Facebook registered"
        Winbits.showCompleteRegistrationLayer $, data.response.profile

    error: (xhr, textStatus, errorThrown) ->
      console.log "facebook.json error!"
      error = JSON.parse(xhr.responseText)
      alert error.meta.message


Winbits.Handlers =
  getTokensHandler: (tokensDef) ->
    Winbits.segregateTokens Winbits.jQuery, tokensDef
    Winbits.expressLogin Winbits.jQuery

  facebookStatusHandler: (response) ->
    console.log ["Facebook status", response]
    if response.status is "connected"
      Winbits.Flags.fbConnect = true
      $.ajax Winbits.config.apiUrl + "/affiliation/express-facebook-login.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(facebookId: response.authResponse.userID)
        headers:
          "Accept-Language": "es"

        xhrFields:
          withCredentials: true

        context: $
        success: (data) ->
          console.log "express-facebook-login.json Success!"
          console.log ["data", data]
          Winbits.applyLogin $, data.response

        error: (xhr, textStatus, errorThrown) ->
          console.log "express-facebook-login.json Error!"

    else
      Winbits.loadVirtualCart Winbits.jQuery

  facebookLoginHandler: (response) ->
    console.log ["Facebook Login", response]
    if response.authResponse
      console.log "Requesting facebook profile..."
      Winbits.proxy.post action: "facebookMe"
    else
      console.log "Facebook login failed!"

  facebookMeHandler: (response) ->
    console.log ["Response from winbits-facebook me", response]
    if response.email
      console.log "Trying to log with facebook"
      Winbits.loginFacebook response

Winbits.EventHandlers = clickDeleteCartDetailLink: (e) ->
  $cartDetail = Winbits.jQuery(e.target).closest("li")
  if Winbits.Flags.loggedIn
    Winbits.deleteUserCartDetail $cartDetail
  else
    Winbits.deleteVirtualCartDetail $cartDetail

Winbits.addToCart = (cartItem) ->
  console.log ["Vertical request to add item to cart", cartItem]
  alert "Please specify a cart item object: {id: 1, quantity: 1}"  unless cartItem
  alert "Id required! Please specify a cart item object: {id: 1, quantity: 1}"  unless cartItem.id
  cartItem.id = parseInt(cartItem.id)
  if not cartItem.quantity or cartItem.quantity < 1
    console.log "Setting default quantity (1)..."
    cartItem.quantity = 1
  cartItem.quantity = parseInt(cartItem.quantity)
  $cartDetail = Winbits.$widgetContainer.find(".cart-holder:visible .cart-details-list").children("[data-id=" + cartItem.id + "]")
  if $cartDetail.length is 0
    if Winbits.Flags.loggedIn
      Winbits.addToUserCart cartItem.id, cartItem.quantity, cartItem.bits
    else
      Winbits.addToVirtualCart cartItem.id, cartItem.quantity
  else
    qty = cartItem.quantity + parseInt($cartDetail.find(".cart-detail-quantity").val())
    Winbits.updateCartDetail $cartDetail, qty, cartItem.bits

Winbits.addToUserCart = (id, quantity, bits) ->
  console.log "Adding to user cart..."
  $ = Winbits.jQuery
  formData =
    skuProfileId: id
    quantity: quantity
    bits: bits

  $.ajax Winbits.config.apiUrl + "/orders/cart-items.json",
    type: "POST"
    contentType: "application/json"
    dataType: "json"
    data: JSON.stringify(formData)
    headers:
      "Accept-Language": "es"
      "WB-Api-Token": Winbits.getCookie(Winbits.apiTokenName)

    success: (data) ->
      console.log ["V: User cart", data.response]
      Winbits.refreshCart $, data.response, true

    error: (xhr, textStatus, errorThrown) ->
      error = JSON.parse(xhr.responseText)
      alert error.meta.message

    complete: ->
      console.log "Request Completed!"


Winbits.storeVirtualCart = ($, cart) ->
  console.log ["Storing virtual cart...", cart]
  vCart = []
  $.each cart.cartDetails or [], (i, cartDetail) ->
    vCartDetail = {}
    vCartDetail[cartDetail.skuProfile.id] = cartDetail.quantity
    vCart.push vCartDetail

  vCartToken = JSON.stringify(vCart)
  console.log ["vCartToken", vCartToken]
  Winbits.setCookie Winbits.vcartTokenName, vCartToken, 7
  Winbits.proxy.post
    action: "storeVirtualCart"
    params: [vCartToken]


Winbits.refreshCart = ($, cart, showCart) ->
  console.log ["Refreshing cart...", cart]
  $cartHolder = Winbits.$widgetContainer.find(".cart-holder:visible")
  $cartHolder.find(".cart-items-count").text cart.itemsCount or 0
  $cartInfo = $cartHolder.find(".cart-info")
  $cartInfo.find(".cart-shipping-total").text cart.shippingTotal or "GRATIS"
  cartTotal = (cart.itemsTotal or 0) + (cart.shippingTotal or 0) - (cart.bitsTotal or 0)
  $cartInfo.find(".cart-total").text "$" + cartTotal
  $cartInfo.find(".cart-bits-total").text cart.bitsTotal or 0
  cartSaving = 0
  $cartInfo.find(".cart-saving").text cartSaving + "%"
  $cartDetailsList = $cartHolder.find(".cart-details-list").html("")
  $.each cart.cartDetails or [], (i, cartDetail) ->
    Winbits.addCartDetailInto $, cartDetail, $cartDetailsList

  $cartHolder.find(".shopCarMin").trigger "click"  if showCart and not $cartHolder.find(".dropMenu").is(":visible")

Winbits.addCartDetailInto = ($, cartDetail, cartDetailsList) ->
  console.log ["Adding cart detail...", cartDetail]
  $cartDetailsList = Winbits.$(cartDetailsList)
  $cartDetail = $("<li>" + "<a href=\"#\"><img class=\"cart-detail-thumb\" width=\"35\" height=\"45\"></a>" + "<p class=\"descriptionItem cart-detail-name\"></p>" + "<label>Cantidad</label>" + "<input type=\"text\" class=\"inputStepper cart-detail-quantity\">" + "<p class=\"priceItem cart-detail-attr\"\"></p>" + "<p class=\"priceItem cart-detail-price\"></p>" + "<span class=\"verticalName\">Producto de <em class=\"cart-detail-vertical\"></em></span>" + "<span class=\"deleteItem\"><a href=\"#\" class=\"cart-detail-delete-link\">eliminar</a></span>" + "</li>")
  $cartDetail.attr "data-id", cartDetail.skuProfile.id
  $cartDetail.find(".cart-detail-thumb").attr("src", cartDetail.skuProfile.item.thumbnail).attr "alt", "[thumbnail]"
  $cartDetail.find(".cart-detail-name").text cartDetail.skuProfile.item.name
  customStepper($cartDetail.find(".cart-detail-quantity").val(cartDetail.quantity)).on "step", (e, previous) ->
    $cartDetailStepper = $(this)
    val = parseInt($cartDetailStepper.val())
    unless previous is val
      console.log ["previous", "current", previous, val]
      Winbits.updateCartDetail $cartDetailStepper.closest("li"), val

  attr = cartDetail.skuProfile.attributes[0]
  $cartDetail.find(".cart-detail-attr").text attr.label + ": " + attr.value  if attr
  $cartDetail.find(".cart-detail-price").text "$" + cartDetail.skuProfile.price
  $cartDetail.find(".cart-detail-vertical").text cartDetail.skuProfile.item.vertical.name
  $cartDetail.find(".cart-detail-delete-link").click Winbits.EventHandlers.clickDeleteCartDetailLink
  $cartDetail.appendTo $cartDetailsList

Winbits.updateCartDetail = (cartDetail, quantity, bits) ->
  $cartDetail = Winbits.$(cartDetail)
  if Winbits.Flags.loggedIn
    Winbits.updateUserCartDetail $cartDetail, quantity, bits
  else
    Winbits.updateVirtualCartDetail $cartDetail, quantity

Winbits.updateUserCartDetail = (cartDetail, quantity, bits) ->
  console.log ["Updating cart detail...", cartDetail]
  $cartDetail = Winbits.$(cartDetail)
  $ = Winbits.jQuery
  formData =
    quantity: quantity
    bits: bits or 0

  id = $cartDetail.attr("data-id")
  $.ajax Winbits.config.apiUrl + "/orders/cart-items/" + id + ".json",
    type: "PUT"
    contentType: "application/json"
    dataType: "json"
    data: JSON.stringify(formData)
    headers:
      "Accept-Language": "es"
      "WB-Api-Token": Winbits.getCookie(Winbits.apiTokenName)

    success: (data) ->
      console.log ["V: User cart", data.response]
      Winbits.refreshCart $, data.response, true

    error: (xhr, textStatus, errorThrown) ->
      error = JSON.parse(xhr.responseText)
      alert error.meta.message

    complete: ->
      console.log "Request Completed!"


Winbits.deleteUserCartDetail = (cartDetail) ->
  console.log ["Deleting user cart detail...", cartDetail]
  $ = Winbits.jQuery
  $cartDetail = Winbits.$(cartDetail)
  id = $cartDetail.attr("data-id")
  $.ajax Winbits.config.apiUrl + "/orders/cart-items/" + id + ".json",
    type: "DELETE"
    dataType: "json"
    headers:
      "Accept-Language": "es"
      "WB-Api-Token": Winbits.getCookie(Winbits.apiTokenName)

    success: (data) ->
      console.log ["V: User cart", data.response]
      Winbits.refreshCart $, data.response

    error: (xhr, textStatus, errorThrown) ->
      error = JSON.parse(xhr.responseText)
      alert error.meta.message

    complete: ->
      console.log "Request Completed!"


Winbits.addToVirtualCart = (id, quantity) ->
  console.log "Adding to virtual cart..."
  $ = Winbits.jQuery
  formData =
    skuProfileId: id
    quantity: quantity
    bits: 0

  $.ajax Winbits.config.apiUrl + "/orders/virtual-cart-items.json",
    type: "POST"
    contentType: "application/json"
    dataType: "json"
    data: JSON.stringify(formData)
    headers:
      "Accept-Language": "es"
      "wb-vcart": Winbits.getCookie(Winbits.vcartTokenName)

    success: (data) ->
      console.log ["V: Virtual cart", data.response]
      Winbits.storeVirtualCart $, data.response
      Winbits.refreshCart $, data.response, true

    error: (xhr, textStatus, errorThrown) ->
      error = JSON.parse(xhr.responseText)
      console.log error.meta.message

    complete: ->
      console.log "Request Completed!"


Winbits.updateVirtualCartDetail = (cartDetail, quantity) ->
  console.log ["Updating cart detail...", cartDetail]
  $cartDetail = Winbits.$(cartDetail)
  $ = Winbits.jQuery
  formData = quantity: quantity
  id = $cartDetail.attr("data-id")
  $.ajax Winbits.config.apiUrl + "/orders/virtual-cart-items/" + id + ".json",
    type: "PUT"
    contentType: "application/json"
    dataType: "json"
    data: JSON.stringify(formData)
    headers:
      "Accept-Language": "es"
      "wb-vcart": Winbits.getCookie(Winbits.vcartTokenName)

    success: (data) ->
      console.log ["V: Virtual cart", data.response]
      Winbits.storeVirtualCart $, data.response
      Winbits.refreshCart $, data.response, true

    error: (xhr, textStatus, errorThrown) ->
      error = JSON.parse(xhr.responseText)
      console.log error.meta.message

    complete: ->
      console.log "Request Completed!"


Winbits.deleteVirtualCartDetail = (cartDetail) ->
  console.log ["Deleting virtual cart detail...", cartDetail]
  $ = Winbits.jQuery
  $cartDetail = Winbits.$(cartDetail)
  id = $cartDetail.attr("data-id")
  $.ajax Winbits.config.apiUrl + "/orders/virtual-cart-items/" + id + ".json",
    type: "DELETE"
    dataType: "json"
    headers:
      "Accept-Language": "es"
      "wb-vcart": Winbits.getCookie(Winbits.vcartTokenName)

    success: (data) ->
      console.log ["V: User cart", data.response]
      Winbits.storeVirtualCart $, data.response
      Winbits.refreshCart $, data.response

    error: (xhr, textStatus, errorThrown) ->
      error = JSON.parse(xhr.responseText)
      console.log error.meta.message

    complete: ->
      console.log "Request Completed!"


console.log "---------->"
(->

  # Localize jQuery variable
  #

  # Async load facebook
  # Winbits.loadFacebook();

  ###
  Load jQuery if not present ********
  ###
  # For old versions of IE

  # Try to find the head, otherwise default to the documentElement

  # The jQuery version on the window is the one we want to use

  ###
  Called once jQuery has loaded *****
  ###
  scriptLoadHandler = ->

    # Restore $ and window.jQuery to their previous values and store the
    # new jQuery in our local jQuery variable
    Winbits.jQuery = window.jQuery.noConflict(true)
    jQuery = Winbits.jQuery

    # Call our main function
    main()

  # Check for presence of required DOM elements or other JS your widget depends on

  ###
  Load HTML ******
  ###

  #Winbits.$widgetContainer.append('<script type="text/javascript" src="' + Winbits.config.baseUrl  + '/include/js/extra.js"></script>" ');

  ###
  Our main function *******
  ###
  main = ->
    Winbits.jQuery.extend Winbits.config, Winbits.userConfig or {}
    $head = Winbits.jQuery("head")
    styles = [Winbits.config.baseUrl + "/include/css/style.css"]

    #loadStylesInto(styles, $head);
    #     var scripts = [
    #     Winbits.config.baseUrl + "/js/porthole.min.js",
    #     Winbits.config.baseUrl + "/include/js/libs/modernizr-2.6.2.js",
    #     Winbits.config.baseUrl + "/include/js/libs/jquery-1.8.3.min.js",
    #     Winbits.config.baseUrl + "/include/js/libs/jquery.browser.min.js",
    #     Winbits.config.baseUrl + "/include/js/libs/jQueryUI1.9.2/jquery-ui-1.9.2.js",
    #     Winbits.config.baseUrl + "/include/js/libs/Highslide/highslide.js",
    #     Winbits.config.baseUrl + "/include/js/libs/jquery.validate.min.js"
    #     ];
    #     Winbits.requiredScriptsCount = scripts.length;
    #     Winbits.loadedScriptsCount = 0;
    #     loadScriptsInto(scripts, $head);
    #     Winbits._readyRetries = 0;
    Winbits._readyInterval = window.setInterval(->

      #      Winbits._readyRetries = Winbits._readyRetries + 1;
      Winbits.winbitsReady()
    , 50)
  loadStylesInto = (styles, e) ->
    $into = Winbits.$(e)
    Winbits.jQuery.each styles, (i, style) ->
      $into.append "<link rel=\"stylesheet\" type=\"text/css\" media=\"all\" href=\"" + style + "\"/>"

  loadScriptsInto = (scripts, e) ->
    $into = Winbits.$(e)
    Winbits.jQuery.each scripts, (i, script) ->
      scriptTag = document.createElement("script")
      scriptTag.setAttribute "type", "text/javascript"
      scriptTag.setAttribute "src", script
      if scriptTag.readyState
        scriptTag.onreadystatechange = -> # For old versions of IE
          Winbits.loadedScriptsCount = Winbits.loadedScriptsCount + 1  if @readyState is "complete" or @readyState is "loaded"
      else
        scriptTag.onload = ->
          Winbits.loadedScriptsCount = Winbits.loadedScriptsCount + 1
      $into.append scriptTag

  console.log "---------->>>>> coffeee"
  Winbits.jQuery
  if window.jQuery is `undefined` or window.jQuery.fn.jquery isnt "1.8.3"
    scriptTag = document.createElement("script")
    scriptTag.setAttribute "type", "text/javascript"
    scriptTag.setAttribute "src", "http://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"
    if scriptTag.readyState
      scriptTag.onreadystatechange = ->
        scriptLoadHandler()  if @readyState is "complete" or @readyState is "loaded"
    else
      scriptTag.onload = scriptLoadHandler
    (document.getElementsByTagName("head")[0] or document.documentElement).appendChild scriptTag
  else
    Winbits.jQuery = window.jQuery
    main()
  Winbits.winbitsReady = ->
    $widgetContainer = Winbits.jQuery("#" + Winbits.config.winbitsDivId)
    if $widgetContainer.length > 0
      window.clearInterval Winbits._readyInterval
      $ = Winbits.jQuery
      Winbits.$widgetContainer = $widgetContainer.first()
      Winbits.$widgetContainer.load Winbits.config.baseUrl + "/widget.html", ->
        Winbits.initProxy $

)() # We call our anonymous function immediately

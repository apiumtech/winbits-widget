#var console = window.console || {};
#console.log = console.log || function () {};
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



Winbits.alertErrors = ($) ->
  params = Winbits.getUrlParams()
  alert params._wb_error  if params._wb_error


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


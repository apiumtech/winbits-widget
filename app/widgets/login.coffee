module.exports = (app) ->
  app.initLoginWidget = ($) ->
    app.$widgetContainer.find("#login-form").submit (e) ->
      e.preventDefault()
      $form = $(this)
      formData = verticalId: app.config.verticalId
      formData = app.Forms.serializeForm($, $form, formData)
      console.log ["Login Data", formData]
      $.ajax app.config.apiUrl + "/affiliation/login.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(formData)
        xhrFields:
          withCredentials: true

        context: $form
        beforeSend: ->
          app.validateForm this

        headers:
          "Accept-Language": "es"

        success: (data) ->
          console.log "Request Success!"
          console.log ["data", data]
          app.applyLogin $, data.response
          $.fancybox.close()

        error: (xhr, textStatus, errorThrown) ->
          console.log xhr
          error = JSON.parse(xhr.responseText)
          app.renderLoginFormErrors this, error

        complete: ->
          console.log "Request Completed!"

  app.applyLogin = ($, profile) ->
    app.Flags.loggedIn = true
    app.checkCompleteRegistration $
    console.log "Logged In"
    app.saveApiToken profile.apiToken
    app.restoreCart $
    app.$widgetContainer.find("div.login").hide()
    app.$widgetContainer.find("div.miCuentaPanel").show()
    app.loadUserProfile $, profile

  app.renderLoginFormErrors = (form, error) ->
    $ = app.jQuery
    $form = app.$(form)
    if error.meta.code is "AFER004"
      $resendConfirmLink = $("<a href=\"" + error.response.resendConfirmUrl + "\">Reenviar correo de confirmaci&oacute;n</a>")
      $resendConfirmLink.click (e) ->
        e.preventDefault()
        app.resendConfirmLink $, e.target

      $errorMessageHolder = $("<p>" + error.meta.message + ". <span class=\"link-holder\"></span></p>")
      $errorMessageHolder.find(".link-holder").append $resendConfirmLink
      message = error.message or error.meta.message
      $errors = $form.find(".errors")
      $errors.children().remove()
      $errors.append $errorMessageHolder
    else
      message = error.message or error.meta.message
      $form.find(".errors").html "<p>" + message + "</p>"

  app.checkCompleteRegistration = ($) ->
    params = app.getUrlParams()
    registerConfirmation = params._wb_register_confirm
    app.showCompleteRegistrationLayer $  if registerConfirmation

  app.showCompleteRegistrationLayer = ($, profile) ->
    $.fancybox.close()
    app.loadCompleteRegisterForm $, profile
    $("a[href=#complete-register-layer]").click()

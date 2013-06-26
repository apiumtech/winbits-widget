module.exports = (app) ->
  app.renderRegisterFormErrors = (form, error) ->
    $form = app.$(form)
    code = error.code or error.meta.code
    if code is "AFER001"
      message = error.message or error.meta.message
      $form.find(".errors").html "<p>" + message + "</p>"

  app.showRegisterConfirmation = ($) ->
    setTimeout (->
      $("a[href=#register-confirm-layer]").click()
    ), 1000

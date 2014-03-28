View = require 'views/base/view'
utils = require 'lib/utils'
config = require 'config'
$ = Winbits.$

module.exports = class LoginView extends View
  container: 'header'
  id: 'wbi-login-modal'
  className: 'wbc-hide'
  template: require './templates/login'

  initialize: ->
    super
    @delegate 'click', '#wbi-login-in-btn', @doLogin

  attach: ->
    super
    @showAsModal()
    @$('form#wbi-login-form').validate
      rules:
        email:
          required: true
          email: true
        password:
          required: true
          minlength: 6

  showAsModal: ->
    $('<a>').wbfancybox(href: '#' + @id, onClosed: -> utils.redirectToNotLoggedInHome()).click()

  doLogin:(e) ->
    $form = $(e.currentTarget).closest('form')
    console.log ['Valid', $form, $form.valid()]
    if utils.validateForm($form)
      formData = verticalId: 1
      formData = utils.serializeForm($form, formData)
      submitButton = @$('#wbi-login-in-btn').prop('disabled', true)
      utils.ajaxRequest(config.apiUrl + "/users/login.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(formData)
        context: @
        headers:
          "Accept-Language": "es"
        success: @doLoginSuccess
        error: @doLoginError
        complete: ->
          submitButton.prop('disabled', false)
      )
    else
      'Fail to login'

  doLoginSuccess: (data) ->
    $.fancybox.close()
    utils.redirectTo controller: 'logged-in', action: 'index', params: data.response

  doLoginError: (xhr) ->
    error = JSON.parse(xhr.responseText)
    @$('.errorDiv p').text(error.meta.message)

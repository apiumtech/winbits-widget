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

  showAsModal: ->
    $('<a>').wbfancybox(href: '#' + @id, onClosed: -> utils.redirectToNotLoggedInHome()).click()

  doLogin:(e) ->
    console.log 'Do login!!!'
    $form = @$("#wbi-login-form")
    formData = verticalId: 1
    formData = utils.serializeForm($form, formData)
    if utils.validateForm($form)
      submitButton = @$('#wbi-login-in-btn').prop('disabled', true)
      utils.ajaxRequest(
        config.apiUrl + "/users/login.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(formData)
        headers:
          "Accept-Language": "es"
        success: @doLoginSuccess
        error: (xhr) ->
          alert 'login error'
        complete: ->
          submitButton.prop('disabled', false)
      )
    else
      'Fail to login'

  doLoginSuccess: (data) ->
    $.fancybox.close()
    utils.redirectTo controller: 'logged-in', action: 'index', params: data.response

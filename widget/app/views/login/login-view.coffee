View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$
env = Winbits.env

module.exports = class LoginView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-login-modal'
  template: require './templates/login'

  initialize: ->
    super
#    @listenTo @model, 'change', @render
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
    if utils.validateForm($form)
      formData = verticalId: env.get('vertical').id
      formData = utils.serializeForm($form, formData)
      submitButton = @$('#wbi-login-in-btn').prop('disabled', true)
      utils.ajaxRequest(env.get('api-url') + "/users/login.json",
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

  doLoginError: (xhr, textStatus) ->
    error = utils.safeParse(xhr.responseText)
    message = if error then error.meta.message else textStatus
    @$('.errorDiv p').text(message)

View = require 'views/base/view'
utils = require 'lib/utils'
loginUtil = require 'lib/login-utils'
$ = Winbits.$
env = Winbits.env

module.exports = class LoginView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-login-modal'
  template: require './templates/login'
  model: require 'models/login/login'

  initialize: ->
    super
    @delegate 'click', '#wbi-login-in-btn', @doLogin

  attach: ->
    super
    @showAsModal()
    @$('.contentModal').customCheckbox();
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
      $submitButton = @$('#wbi-login-in-btn').prop('disabled', yes)

      @model.requestLogin(formData, context: @)
        .done(@doLoginSuccess)
        .fail(@doLoginError)
        .always(-> $submitButton.prop('disabled', false))

  doLoginSuccess: (data) ->
    $.fancybox.close()
    response = data.response
    loginUtil.applyLogin(response)
    utils.redirectTo controller: 'logged-in', action: 'index'

  doLoginError: (xhr, textStatus) ->
    error = utils.safeParse(xhr.responseText)
    message = if error then error.meta.message else textStatus
    @$('.errorDiv p').text(message)

View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$
env = Winbits.env

module.exports = class ModalRegisterView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-recover-password-modal'
  template: require './templates/recover-password'

  initialize: ->
    super
    @delegate 'click', '#wbi-recover-password-btn', @doSendMailRecoverPassword

  attach: ->
    super
    @showAsModal()
    @$('.wbc-recover-password-form').validate
      rules:
        email:
          required: true
          email: true

  showAsModal: ->
    $('<a>').wbfancybox(href: '#wbi-recover-password-modal', onClosed: -> utils.redirectTo controller: 'home', action: 'index').click()

  doSendMailRecoverPassword: (e)->
    e.preventDefault()
    $form =  @$el.find(".wbc-recover-password-form")
    if utils.validateForm($form)
      formData = verticalId: env.get('vertical').id
      formData = utils.serializeForm($form, formData)
      $submitButton = @$('#wbi-recover-password-btn').prop('disabled', yes)

      @model.requestRecoverPassword(formData)
        .done(@doRecoverPasswordSuccess)
        .fail(@doRecoverPasswordError)
        .always(-> $submitButton.prop('disabled', false))

  doRecoverPasswordSuccess :->
    console.log 'Success Request Recover Password'

  doRecoverPasswordError: ->
    console.log 'Success Request Recover Error'
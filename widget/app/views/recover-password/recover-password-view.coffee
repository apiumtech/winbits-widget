View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$
env = Winbits.env

module.exports = class ModalRecoverPasswordView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-recover-password-modal'
  template: require './templates/recover-password'

  initialize: ->
    super
    @delegate 'submit', '#wbi-recover-password-form', @doSendMailRecoverPassword

  attach: ->
    super
    @showAsModal()
    @$('#wbi-recover-password-form').validate
      rules:
        email:
          required: true
          email: true

  showAsModal: ->
    $('<a>').wbfancybox(href: '#wbi-recover-password-modal', onClosed: -> utils.redirectTo controller: 'home', action: 'index').click()

  doSendMailRecoverPassword: (e) ->
    e.preventDefault()

    @$('.errorDiv').css('display':'none')
    $form =  $(e.currentTarget)
    if utils.validateForm($form)
      formData = verticalId: env.get 'current-vertical-id'
      formData = utils.serializeForm($form, formData)
      $submitButton = $form.find('#wbi-recover-password-btn').prop('disabled', yes)

      @model.requestRecoverPassword(formData, context: @)
        .done(@doRecoverPasswordSuccess)
        .fail(@doRecoverPasswordError)
        .always(-> $submitButton.prop('disabled', no))

  doRecoverPasswordSuccess :->
    message = "Te hemos mandado un mensaje a tu cuenta de correo con las instrucciones para recuperar tu contraseña."
    options = value: "Aceptar", title:'Correo enviado', onClosed: utils.redirectTo(controller: 'home', action: 'index'), icon: 'iconFont-email2', acceptAction:() -> $.fancybox.close()
    utils.showMessageModal(message, options)

  doRecoverPasswordError: (xhr, textStatus)->
    error = utils.safeParse(xhr.responseText)
    message = if error then error.meta.message else textStatus
    @$('.errorDiv p').text(message).parent().css('display':'block')
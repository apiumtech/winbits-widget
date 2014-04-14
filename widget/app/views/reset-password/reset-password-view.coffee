View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$
env = Winbits.env

module.exports = class ModalResetPasswordView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-reset-password-modal'
  template: require './templates/reset-password'

  initialize: ->
    super
    @delegate 'click', '#wbi-reset-password-btn', @doResetPassword

  attach: ->
    super
    @showAsModal()
    @$('.wbc-reset-password-form').validate
      rules:
        resetPassword:
          required: true
          minlength: 6
        resetPasswordConfirm:
          required: true
          minlength: 6
          equalTo: @$("[name=resetPassword]")


  showAsModal: ->
    $('<a>').wbfancybox(href: '#wbi-reset-password-modal', onClosed: -> utils.redirectTo controller: 'home', action: 'index').click()

  doResetPassword: (e)->
    e.preventDefault()
    @$('.errorDiv').css('display':'none')
    $form =  @$el.find(".wbc-reset-password-form")


  doRecoverPasswordSuccess :->
    message = "Te hemos mandado un mensaje a tu cuenta de correo con las instrucciones para recuperar tu contraseña."
    options = value: "Aceptar", title:'Correo enviado', onClosed: utils.redirectTo(controller: 'home', action: 'index'), icon: 'iconFont-email2'
    utils.showMessageModal(message, options)
    console.log 'evento publicado'

  doRecoverPasswordError: (xhr, textStatus)->
    error = utils.safeParse(xhr.responseText)
    message = if error then error.meta.message else textStatus
    @$('.errorDiv p').text(message).parent().css('display':'block')
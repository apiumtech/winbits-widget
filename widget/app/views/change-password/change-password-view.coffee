'use strict'

MyProfileView = require 'views/my-profile/my-profile-view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class ChangePasswordView extends MyProfileView
  container: '#wb-profile'
  id : 'wbi-change-password'
  template: require './templates/change-password'

  initialize: ->
    super
    @listenTo @model,  'change', @render
    @delegate 'click', '#wbi-change-password-btn', @changePassword

  attach: ->
    super
    @$el.prop 'class', 'column miCuenta-password'
    @$('.requiredField').requiredField()
    @$('#wbi-change-password-form').validate
      errorElement: 'span',
      rules:
        password:
          required: yes
          minlength: 6
        newPassword:
          required: yes
          minlength: 6
        passwordConfirm:
          required: yes
          minlength: 6
          equalTo: @$('[name=newPassword]')

  changePassword : (e) ->
    $form = @$('#wbi-change-password-form')
    data = utils.serializeProfileForm $form
    if($form.valid())
      submitButton = @$(e.currentTarget).prop('disabled', yes)
      @model.requestChangePassword(data, context: @)
      .done(@doChangePasswordSuccess)
      .fail(@doChangePasswordError)
      .always(@doChangePasswordAlways(submitButton))

  doChangePasswordAlways: (submitButton)->
    submitButton.prop('disabled', no)
    @doResetPasswordView



  doChangePasswordSuccess: (data) ->
    console.log "Request Change Password Success!"
    message = "Tu password fue actualizado correctamente."
    options = value: "Continuar", title:'Cambio de password exitoso', icon:'iconFont-ok', onClosed: utils.redirectTo controller:'my-account', action:'index'
    utils.showMessageModal(message, options)


  doChangePasswordError: (xhr, textStatus)->
    error = utils.safeParse(xhr.responseText)
    messageText = "Error cambiando el password #{textStatus}"
    message = if error then error.meta.message else messageText
    options = value: "Cerrar", title:'Error', icon: 'iconFont-no', onClosed: utils.redirectTo controller:'my-account', action:'index'
    utils.showMessageModal(message, options)

  doResetPasswordView: ->
    @$el.find('input[type=password]').val(null)


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
  placeholders: no

  initialize: ->
    super
    @listenTo @model,  'change', @render
    @delegate 'click', '#wbi-change-password-btn', @changePassword

  attach: ->
    super
    @$el.prop 'class', 'column miCuenta-password'
#    @$('.requiredField[name]').requiredField()
    @applyPlaceholders()
    @$('#wbi-change-password-form').validate
      errorElement: 'span',
      rules:
        password:
          required: yes
          minlength: 2
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
      utils.showAjaxLoading()
      @model.requestChangePassword(data, context: @)
      .done(@doChangePasswordSuccess)
      .fail(@doChangePasswordError)
      .always( -> @doChangePasswordAlways(submitButton) )

  doChangePasswordAlways: (submitButton)->
    utils.hideAjaxLoading()
    submitButton.prop('disabled', no)

  doChangePasswordSuccess: (data) ->
    message = "Tu contraseña se ha actualizado correctamente."
    options =
      value: "Aceptar"
      title:'Actualización de contraseña'
      icon:'iconFont-document'
    utils.showMessageModal(message, options)
    @doResetPasswordView()

  doChangePasswordError: (xhr, textStatus)->
    error = utils.safeParse(xhr.responseText)
    messageText = "Error cambiando el password #{textStatus}"
    message = if error then error.meta.message else messageText
    options =
      value: "Cerrar"
      title:'Error'
      icon: 'iconFont-closeCircle'
    utils.showMessageModal(message, options)

  doResetPasswordView: ->
    @render()

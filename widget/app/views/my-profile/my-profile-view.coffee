'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class MyProfileView extends View
  container: '.wbc-my-account-container'
  id: 'wbi-my-profile'
  template: require './templates/my-profile'

  initialize: ->
    super
    @listenTo @model, 'change', @render
    @delegate 'click', '#wbi-change-password-btn', @changePassword
    @delegate 'click', '#wbi-update-profile-btn', @updateProfile

  attach: ->
    super
    @$('.divGender').customRadio()
    @$('.requiredField').requiredField()
    @$('#wbi-personal-data-form').validate
      rules:
        name:
          required: yes
          minlength:2
        lastName:
          required: yes
          minlength: 2
#        gender:
#          required: yes
    @$('#wbi-change-password-form').validate
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
          equalTo: '[name=newPassword]'

  updateProfile : (e) ->
    $form = @$('#wbi-personal-data-form')
    data = utils.serializeProfileForm $form
    if($form.valid())
      submitButton = @$(e.currentTarget).prop('disabled', yes)
      @model.requestUpdateProfile(data, context: @)
      .done(@doUpdateProfileSuccess)
      .fail(@doUpdateProfileError)
      .always -> submitButton.prop('disabled', no)

  doUpdateProfileSuccess: (data) ->
    @publishEvent 'profile-changed', data
    mediator.data.set 'login-data', data.response


  doUpdateProfileError: (xhr, textStatus)->
    error = utils.safeParse(xhr.responseText)
    messageText = "Error guardando el registro #{textStatus}"
    message = if error then error.meta.message else messageText
    options = value: "Cerrar", title:'Error', onClosed: utils.redirectToLoggedInHome()
    utils.showMessageModal(message, options)



  changePassword : (e) ->
    console.log [e]
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
  #TODO: revisar el reseteo de los campos de password



  doChangePasswordSuccess: (data) ->
    console.log "Request Change Password Success!"
    message = "Tu password fue actualizado correctamente."
    options = value: "Continuar", title:'Cambio de password exitoso', icon:'iconFont-ok', onClosed: utils.redirectTo controller:'my-profile', action:'index'
    utils.showMessageModal(message, options)


  doChangePasswordError: (xhr, textStatus)->
    error = utils.safeParse(xhr.responseText)
    messageText = "Error cambiando el password #{textStatus}"
    message = if error then error.meta.message else messageText
    options = value: "Cerrar", title:'Error', icon: 'iconFont-no', onClosed: utils.redirectTo controller:'my-profile', action:'index'
    utils.showMessageModal(message, options)
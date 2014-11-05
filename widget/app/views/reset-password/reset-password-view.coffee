View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$
env = Winbits.env
mediator = Winbits.Chaplin.mediator

module.exports = class ModalResetPasswordView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-reset-password-modal'
  template: require './templates/reset-password'

  initialize: ->
    super
    @delegate 'click', '#wbi-reset-password-btn', @doResetPassword

  attach: ->
    super
    @$('.wbc-reset-password-form').validate
      rules:
        password:
          required: true
          minlength: 6
        passwordConfirm:
          required: true
          minlength: 6
          equalTo: @$("[name=password]")
    @showAsModal()


  showAsModal: ->
    $('<a>').wbfancybox(href: '#wbi-reset-password-modal', onClosed: -> utils.redirectTo controller: 'home', action: 'index').click()

  doResetPassword: (e)->
    e.preventDefault()
    @$('.errorDiv').css('display':'none')
    $form =  @$el.find(".wbc-reset-password-form")

    if utils.validateForm($form)
      formData = utils.serializeForm($form)
      formData.hash =  mediator.data.get('salt').salt
      $submitButton = @$(e.currentTarget).prop('disabled', yes)

      @model.requestResetPassword(formData, context:@)
        .done(@doResetPasswordSuccess)
        .fail(@doResetPasswordError)
        .always(-> $submitButton.prop('disabled', no))


  doResetPasswordSuccess: ->
    message = "Tu contraseña se ha actualizado correctamente."
    options = value: "Aceptar", title:'Actualización de contraseña', onClosed: utils.redirectTo(controller: 'home', action: 'index'), icon: 'iconFont-document'
    utils.showMessageModal(message, options)

  doResetPasswordError: (xhr, textStatus)->
    error = utils.safeParse(xhr.responseText)
    message = if error then error.meta.message else textStatus
    @$('.errorDiv p').text(message).parent().css('display':'block')

View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$
env = Winbits.env

module.exports = class ModalRegisterView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-register-modal'
  template: require './templates/register'

  initialize: ->
    super
    @delegate 'click', '#wbi-register-button', @register

  attach: ->
    super
    @showAsModal()
    @$('#wbi-register-form').validate
      rules:
        email:
          required: true
          email: true
        password:
          required: true
          minlength: 6
        passwordConfirm:
          required: true
          minlength: 6
          equalTo: @$("[name=password]")

  showAsModal: ->
    $('<a>').wbfancybox(href: '#wbi-register-modal', onClosed: -> utils.redirectTo controller: 'home', action: 'index').click()

  register: (e)->
    e.preventDefault()
    console.log "RegisterView#register"
    $form =  @$el.find("#wbi-register-form")
    formData = verticalId: env.get('vertical').id
    formData = utils.serializeForm($form, formData)
    if utils.validateForm($form)
      submitButton = @$(e.currentTarget).prop('disabled', true)
      utils.ajaxRequest( env.get('api-url') + "/users/register.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(formData)
        xhrFields:
          withCredentials: true
        context: @
        headers:
          "Accept-Language": "es"
        success: @doRegisterSuccess
        error: @doRegisterError
        complete: ->
          console.log "Request Completed!"
          submitButton.prop('disabled', false)
      )

  doRegisterSuccess: (data) ->
    console.log "Request Success!"
    message = "Gracias por registrarte con nosotros. <br> Un mensaje de confirmación ha sido enviado a tu <br> cuenta de correo."
    options = value: "Continuar", onClosed: utils.redirectTo controller: 'home', action: 'index'
    utils.showMessageModal(message, options)
    console.log 'evento publicado'

  doRegisterError: (xhr, textStatus) ->
    error = utils.safeParse(xhr.responseText)
    message = if error then error.meta.message else textStatus
    console.log xhr
    @$('.errorDiv p').text(message)

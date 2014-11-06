View = require 'views/base/view'
utils = require 'lib/utils'
loginUtils = require 'lib/login-utils'
trackingUtils = require 'lib/tracking-utils'
NotLoggedIn = require 'models/not-logged-in/not-logged-in'
env = Winbits.env
$ = Winbits.$
mediator = Winbits.Chaplin.mediator

module.exports = class NotLoggedInPageView extends View
  container: '#wbi-header-wrapper'
  className: 'miCuenta login log-in'
  template: require './templates/not-logged-in'

  DEFAULT_ERROR_MESSAGE =
    DAFR : 'Para iniciar sesión/registrarse en winbits, es necesario aceptar todos los permisos.'
    DPFR : 'Para iniciar sesión/registrarse en winbits, es necesario aceptar todos los permisos.'
    EIFR : 'Necesitamos un correo electrónico para iniciar sesión. Por favor, ingresa a la sección de Ajustes en tu cuenta de Facebook para cambiar la configuración.'

  DEFAULT_ERROR_TITLE =
    DAFR : 'Inicio de sesión incompleto.'
    DPFR : 'Inicio de sesión incompleto.'
    EIFR : 'E-mail necesario para inicio de sesión winbits.'

  initialize: ->
    super
    @model = new NotLoggedIn
    @delegate 'click', '#wbi-login-btn', @onLoginButtonClick
    @delegate 'click', '#wbi-register-link', @onRegisterLinkClick
    @subscribeEvent 'facebook-button-event', @doFacebookLogin
    @subscribeEvent 'denied-authentication-fb-register', -> @doFacebookLoginErrors.apply(@, arguments)
    @subscribeEvent 'denied-permissions-fb-register', -> @doFacebookLoginErrors.apply(@, arguments)
    @subscribeEvent 'email-inactive-fb-register', -> @doFacebookLoginErrors.apply(@, arguments)
    @subscribeEvent 'success-authentication-fb-register', -> @facebookSuccess.apply(@, arguments)
    @subscribeEvent 'success-authentication-change-fb-link', -> @doFacebookLoginChangeFacebookLink.apply(@, arguments)

  attach: ->
    super
    console.log 'not-logged-in-view#attach'

  onLoginButtonClick: ->
    mediator.data.set 'virtual-checkout', no
    utils.redirectTo controller: 'login', action: 'index'

  onRegisterLinkClick: ->
    utils.redirectTo controller: 'register', action: 'index'

  doFacebookLogin : (e)->
    e?.preventDefault()
    @$(e?.currentTarget).prop('disabled', true)
    @popupFacebookLogin()

  popupFacebookLogin: ->
    popup = window.open( env.get('api-url') + "/users/facebook-login/connect?verticalId=" + env.get('current-vertical-id'),
        "facebook", "menubar=0,resizable=0,width=980,height=500")
    popup.focus()

  facebookSuccess: (response)->
      data =
        facebookId: response.facebookId
        utms: trackingUtils.getUTMs()
      promise = @model.requestExpressFacebookLogin(data, context:@)
      promise.done(@doFacebookLoginSuccess).fail(@doFacebookLoginError)


  doFacebookLoginSuccess: (data) ->
    mediator.data.set 'profile-composed', no
    response = data.response
    loginUtils.applyLogin(response)
    @publishEvent 'logged-in'
    if 201 is data.meta.status
      utils.redirectTo controller:'complete-register', action:'index'
    else
      @doCheckShowRemainder data

  doCheckShowRemainder:(data)->
    if data.response.showRemainder is yes
      message = "Recuerda que puedes ganar <strong>$#{data.response.cashbackForComplete}</strong> en bits al completar tu registro"
      options =
        value: "Completa registro"
        title:'¡Completa tu registro!'
        cancelValue: 'Llénalo después'
        icon:'iconFont-computer'
        context: @
        acceptAction: () ->
          Winbits.$('#wbi-my-account-link').click()
          utils.closeMessageModal()
      utils.showConfirmationModal(message, options)
    else
      $.fancybox.close()
    utils.redirectToLoggedInHome()

  doFacebookLoginError: (xhr, textStatus, errorThrown) ->
    console.log "express-facebook-login.json Error!"

  doFacebookLoginErrors: (data)->
    @$('#wbi-login-facebook-link').prop('disabled', no)
    message = DEFAULT_ERROR_MESSAGE[data.errorCode]
    options =
      value : 'Aceptar'
      title : DEFAULT_ERROR_TITLE[data.errorCode]
      icon  : 'iconFont-facebookCircle'
      context: @
      onClosed: () -> @doCloseConfirmModal()
      acceptAction: () -> @doCloseConfirmModal()
    utils.showMessageModal(message, options)

  doFacebookLoginChangeFacebookLink: (data)->
    @$('#wbi-login-facebook-link').prop('disabled', no)
    message = "La cuenta de facebook que tenías ligada ha sido cambiada."
    options =
      value : 'Aceptar'
      title : 'Cambio la cuenta ligada.'
      icon  : 'iconFont-facebookCircle'
      context: @
      onClosed: () => @facebookSuccess(data)
    utils.showMessageModal(message, options)

  doCloseConfirmModal: ->
    utils.redirectTo action: 'index', controller:'home'
    utils.closeMessageModal()

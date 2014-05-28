View = require 'views/base/view'
utils = require 'lib/utils'
loginUtils = require 'lib/login-utils'
env = Winbits.env
NotLoggedIn = require 'models/not-logged-in/not-logged-in'
$ = Winbits.$
mediator = Winbits.Chaplin.mediator


module.exports = class NotLoggedInPageView extends View
  container: '#wbi-header-wrapper'
  className: 'miCuenta login'
  template: require './templates/not-logged-in'

  initialize: ->
    super
    @model = new NotLoggedIn
    @delegate 'click', '#wbi-login-btn', @onLoginButtonClick
    @delegate 'click', '#wbi-register-link', @onRegisterLinkClick
    @subscribeEvent 'facebook-button-event', @doFacebookLogin

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
    fbButton = @$(e?.currentTarget).prop('disabled', true)
    popup = @popupFacebookLogin()
    timer = setInterval($.proxy(->
      @facebookLoginInterval(fbButton, popup, timer)
    , @), 100)

  facebookLoginInterval: (fbButton, popup, timer)->
    if popup.closed
      fbButton.prop('disabled', false)
      clearInterval timer
      $.fancybox.close()
      @expressFacebookLogin()

  popupFacebookLogin: ->
    popup = window.open( env.get('api-url') + "/users/facebook-login/connect?verticalId=" + env.get('current-vertical-id'),
        "facebook", "menubar=0,resizable=0,width=800,height=500")
    popup.focus()
    popup

  expressFacebookLogin: ->
    env.get('rpc').facebookStatus $.proxy(@facebookStatusSuccess, @)

  facebookStatusSuccess: (response)->
    if response.status is "connected"
      data = facebookId: response.authResponse.userID
      promise = @model.requestExpressFacebookLogin(data, context:@)
      promise.done(@doFacebookLoginSuccess).fail(@doFacebookLoginError)
    else
      console.log "not conected to facebook "


  doFacebookLoginSuccess: (data) ->
    mediator.data.set 'profile-composed', no
    response = data.response
    loginUtils.applyLogin(response)
    if 201 is data.meta.status
      console.log ["Show Complete Register.", data.response.profile]
      utils.redirectTo controller:'complete-register', action:'index'
    else
      utils.redirectToLoggedInHome()
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
      utils.showConfirmationModal(message, options)
    else
      $.fancybox.close()

  doFacebookLoginError: (xhr, textStatus, errorThrown) ->
    console.log "express-facebook-login.json Error!"
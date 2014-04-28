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
    utils.redirectTo controller: 'login', action: 'index'

  onRegisterLinkClick: ->
    utils.redirectTo controller: 'register', action: 'index'

  doFacebookLogin : (e)->
    e?.preventDefault()
    that = @
    fbButton = @$(e?.currentTarget).prop('disabled', true)
    popup = @popupFacebookLogin()
    timer = setInterval(->
      that.facebookLoginInterval(fbButton, popup, timer)
    , 100)

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
    that = @
    console.log ['api-url', Winbits.env.get('api-url')]
    console.log ['rpc', env.get('rpc')]
    env.get('rpc').facebookStatus (response)->
      console.log ['status', response]
      if response.status is "connected"
        data = facebookId: response.authResponse.userID
        that.model.requestExpressFacebookLogin(data, context:@ )
          .done(that.doFacebookLoginSuccess)
          .fail(that.doFacebookLoginError)
      else
        console.log "not conected to facebook "

  doFacebookLoginSuccess: (data) ->
    console.log "express-facebook-login.json Success!"
    console.log ["data", data]
    mediator.data.set 'profile-composed', no
    response = data.response
    loginUtils.applyLogin(response)
    if 201 is data.meta.status
      console.log ["Show Complete Register.", data.response.profile]
      utils.redirectTo controller:'complete-register', action:'index'
    else
      utils.redirectToLoggedInHome()

  doFacebookLoginError: (xhr, textStatus, errorThrown) ->
    console.log "express-facebook-login.json Error!"
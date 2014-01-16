mediator = require 'chaplin/mediator'
EventBroker = require 'chaplin/lib/event_broker'
token = require 'lib/token'
config = require 'config'
util = require 'lib/util'

module.exports = class ProxyHandlers

  # Mixin an EventBroker
  _(@prototype).extend EventBroker

  constructor:()->
    @.initialize.apply this, arguments
    console.log "ProxyHandlers#constructor"


  initialize: ->
    @subscribeEvent 'getTokensHandler', @getTokensHandler
    @subscribeEvent 'facebookStatusHandler', @facebookStatusHandler
    @subscribeEvent 'facebookLoginHandler', @facebookLoginHandler
    @subscribeEvent 'facebookMeHandler', @facebookMeHandler

  getTokensHandler: (tokensDef) ->
    console.log ["Handle response for: getTokensHandler...", tokensDef]
    token.segregateTokens tokensDef
    @publishEvent 'expressLogin'


  facebookStatusHandler: (response) ->
    console.log ["Handle response for: facebookStatus...", response]

    if response.status is "connected"

      that = @
      mediator.flags.fbConnect = true
      util.ajaxRequest( config.apiUrl + "/users/express-facebook-login.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(facebookId: response.authResponse.userID)
        headers:
          "Accept-Language": "es"
        xhrFields:
          withCredentials: true
        success: (data) ->
          console.log "express-facebook-login.json Success!"
          console.log ["data", data]
          that.publishEvent "applyLogin", data.response
          if 201 is data.meta.status
            console.log ["Show Complete Register.", data.response.profile]
            that.publishEvent("setRegisterFb", data.response.profile)
            that.publishEvent "showCompletaRegister", data.response.profile
        error: (xhr, textStatus, errorThrown) ->
          console.log "express-facebook-login.json Error!"
          that.publishEvent 'showRegisterByReferredCode'
      )
    else
      console.log "calling loadVirtualCart"
      @publishEvent "loadVirtualCart"
      @publishEvent 'showRegisterByReferredCode'

  facebookLoginHandler: (response) ->
    console.log ["Handle response for: facebookLogin...", response]
    if response.authResponse
      console.log "Requesting facebook profile..."
      mediator.facebook.accessToken = response.authResponse.accessToken
      Winbits.rpc.facebookMe(@facebookMeHandler)
    else
      console.log "Facebook login failed!"

  facebookMeHandler: (response) ->
    console.log ["Handle response for: facebookMe...", response]
    Winbits.$('.modal').modal 'hide'
    if response.email
      @publishEvent "loginFacebook", response

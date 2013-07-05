mediator = require 'chaplin/mediator'
EventBroker = require 'chaplin/lib/event_broker'
token = require 'lib/token'
config = require 'config'

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
    console.log ["getTokensHandler", tokensDef]
    token.segregateTokens tokensDef
    console.log "<3"
    @publishEvent 'expressLogin'
    console.log "</3"


  facebookStatusHandler: (response) ->
    console.log ["Facebook status", response]
    if response.status is "connected"
      mediator.Flags.fbConnect = true
      $.ajax config.apiUrl + "/affiliation/express-facebook-login.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(facebookId: response.authResponse.userID)
        headers:
          "Accept-Language": "es"

        xhrFields:
          withCredentials: true

        context: $
        success: (data) ->
          console.log "express-facebook-login.json Success!"
          console.log ["data", data]
          app.applyLogin $, data.response

        error: (xhr, textStatus, errorThrown) ->
          console.log "express-facebook-login.json Error!"

    else
      app.loadVirtualCart app.jQuery

  facebookLoginHandler: (response) ->
    console.log ["Facebook Login", response]
    if response.authResponse
      console.log "Requesting facebook profile..."
      app.proxy.post action: "facebookMe"
    else
      console.log "Facebook login failed!"

  facebookMeHandler: (response) ->
    console.log ["Response from winbits-facebook me", response]
    if response.email
      console.log "Trying to log with facebook"
      app.loginFacebook response


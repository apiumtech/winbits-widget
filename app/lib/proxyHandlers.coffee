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

    if response[0].status is "connected"

      that = @
      mediator.flags.fbConnect = true
      Backbone.$.ajax config.apiUrl + "/affiliation/express-facebook-login.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(facebookId: response[0].authResponse.userID)
        headers:
          "Accept-Language": "es"

        xhrFields:
          withCredentials: true

        context: Backbone.$
        success: (data) ->
          console.log "express-facebook-login.json Success!"
          console.log ["data", data]
          #app.applyLogin $, data.response
          that.publishEvent "applyLogin", data.response

        error: (xhr, textStatus, errorThrown) ->
          console.log "express-facebook-login.json Error!"

    else
      console.log "calling loadVirtualCart"
      @publishEvent "loadVirtualCart"

  facebookLoginHandler: (response) ->
    console.log ["Facebook Login", response]
    if response[0].authResponse
      console.log "Requesting facebook profile..."
      mediator.proxy.post action: "facebookMe"
    else
      console.log "Facebook login failed!"

  facebookMeHandler: (response) ->
    console.log ["Response from winbits-facebook me", response[0].email]
    Backbone.$('.modal').modal 'hide'
    if response[0].email
      console.log "Trying to log with facebook2"
      @publishEvent "loginFacebook", response[0]
      console.log "Trying to log with facebook3"


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
    @publishEvent 'expressLogin'


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
          that.publishEvent "applyLogin", data.response
          if 201 is data.meta.status
            console.log ["Show Complete Register.", data.response.profile]
            that.publishEvent("setRegisterFb", data.response.profile)
            that.publishEvent "showCompletaRegister", data.response.profile

        error: (xhr, textStatus, errorThrown) ->
          console.log "express-facebook-login.json Error!"
          that.publishEvent 'showRegisterByReferredCode'

    else
      console.log "calling loadVirtualCart"
      @publishEvent "loadVirtualCart"
      @publishEvent 'showRegisterByReferredCode'

  facebookLoginHandler: (response) ->
    console.log ["Facebook Login", response]
    if response[0].authResponse
      console.log "Requesting facebook profile..."
      mediator.facebook.accessToken = response[0].authResponse.accessToken
      mediator.proxy.post action: "facebookMe"
    else
      console.log "Facebook login failed!"

  facebookMeHandler: (response) ->
    Backbone.$('.modal').modal 'hide'
    if response[0].email
      @publishEvent "loginFacebook", response[0]

util = require 'lib/util'
token = require 'lib/token'
mediator = require 'chaplin/mediator'
EventBroker = require 'chaplin/lib/event_broker'
config = require 'config'

module.exports = class LoginUtil

  _(@prototype).extend EventBroker

  constructor:()->
    @.initialize.apply this, arguments
    console.log "LoginUtil#constructor"

  initialize: ->
    console.log @subscribeEvent
    @subscribeEvent 'expressLogin', @expressLogin
    @subscribeEvent 'applyLogin', @applyLogin
    @subscribeEvent 'initLogout', @initLogout

  expressLogin : () ->
    #Winbits.checkRegisterConfirmation $
    console.log "expressLogin"
    apiToken = util.getCookie(config.apiTokenName)
    console.log ["API Token", apiToken]
    that = @
    if apiToken
      $.ajax config.apiUrl + "/affiliation/express-login.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(apiToken: apiToken)
        headers:
          "Accept-Language": "es"

        xhrFields:
          withCredentials: true

        context: $
        success: (data) ->
          console.log "express-login.json Success!"
          console.log ["data", data]
          that.applyLogin data.response

        error: (xhr, textStatus, errorThrown) ->
          console.log "express-login.json Error!"
          error = JSON.parse(xhr.responseText)
          alert error.meta.message

    else
      @expressFacebookLogin $

  expressFacebookLogin : ($) ->
    console.log "Trying to login with facebook"
    mediator.proxy.post action: "facebookStatus"

  applyLogin : (profile) ->
    mediator.flags.loggedIn = true
    #Winbits.checkCompleteRegistration $
    console.log "Logged In"
    token.saveApiToken profile.apiToken
    #Winbits.restoreCart $
    #console.log profile.mainShippingAddress
    @publishEvent "showHeaderLogin"
    @publishEvent "fetchCart"
    @publishEvent "setProfile", profile.profile
    #Winbits.$widgetContainer.find("div.login").hide()
    #Winbits.$widgetContainer.find("div.miCuentaPanel").show()
    #Winbits.loadUserProfile $, profile
    #
  initLogout : () ->
    that = this
    console.log "initLogout"
    $.ajax config.apiUrl + "/affiliation/logout.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      xhrFields:
        withCredentials: true

      headers:
        "Accept-Language": "es"

      success: (data) ->
        console.log "logout.json Success!"
        that.applyLogout $, data.response

      error: (xhr, textStatus, errorThrown) ->
        console.log "logout.json Error!"
        error = JSON.parse(xhr.responseText)
        alert error.meta.message

      complete: ->
        console.log "logout.json Completed!"



  applyLogout : ($, logoutData) ->
    mediator.proxy.post
      action: "logout"
      params: [mediator.flags.fbConnect]

    util.deleteCookie config.apiTokenName
    #Winbits.resetWidget $
    mediator.flags.loggedIn = false
    mediator.flags.fbConnect = false

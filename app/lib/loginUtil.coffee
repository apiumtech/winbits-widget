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
    @subscribeEvent 'expressLogin', @expressLogin
    @subscribeEvent 'applyLogin', @applyLogin
    @subscribeEvent 'initLogout', @initLogout
    @subscribeEvent 'loginFacebook', @loginFacebook

  expressLogin : () ->
    #Winbits.checkRegisterConfirmation Backbone.$
    console.log "LoginUtil#expressLogin"
    apiToken = util.getCookie(config.apiTokenName)
    console.log ["API Token", apiToken]
    that = @
    if apiToken
      Backbone.$.ajax config.apiUrl + "/affiliation/express-login.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(apiToken: apiToken)
        headers:
          "Accept-Language": "es"

        xhrFields:
          withCredentials: true

        context: Backbone.$
        success: (data) ->
          console.log "express-login.json Success!"
          console.log ["data", data]
          that.applyLogin data.response

        error: (xhr, textStatus, errorThrown) ->
          console.log "express-login.json Error!"
          error = JSON.parse(xhr.responseText)
          alert error.meta.message

    else
      @expressFacebookLogin Backbone.$

  expressFacebookLogin : ($) ->
    console.log "Trying to login with facebook"
    mediator.proxy.post action: "facebookStatus"

  applyLogin : (profile) ->
    console.log "LoginUtil#applyLogin"
    console.log profile
    console.log "LoginUtil#applyLogin"
    if profile.apiToken
      mediator.flags.loggedIn = true
      #Winbits.checkCompleteRegistration $

      token.saveApiToken profile.apiToken
      #Winbits.restoreCart $
      @publishEvent "showHeaderLogin"
      @publishEvent "restoreCart"
      @publishEvent "setProfile", profile.profile
      @publishEvent "setSubscription", subscriptions:profile.subscriptions


      #Winbits.$widgetContainer.find("div.login").hide()
      #Winbits.$widgetContainer.find("div.miCuentaPanel").show()
      #Winbits.loadUserProfile $, profile
      #
  initLogout : () ->
    that = this
    console.log "initLogout"
    Backbone.$.ajax config.apiUrl + "/affiliation/logout.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      xhrFields:
        withCredentials: true

      headers:
        "Accept-Language": "es"

      success: (data) ->
        console.log "logout.json Success!"
        that.applyLogout data.response

      error: (xhr, textStatus, errorThrown) ->
        console.log "logout.json Error!"
        error = JSON.parse(xhr.responseText)
        alert error.meta.message

      complete: ->
        console.log "logout.json Completed!"



  applyLogout : (logoutData) ->
    mediator.proxy.post
      action: "logout"
      params: [mediator.flags.fbConnect]

    util.deleteCookie config.apiTokenName
    @publishEvent "resetComponents"
    @publishEvent "showHeaderLogout"
    mediator.flags.loggedIn = false
    mediator.flags.fbConnect = false




  loginFacebook : (me) ->
    console.log "was here"
    $ = Backbone.$
    that = @
    myBirthdayDate = new Date(me.birthday)
    birthday = myBirthdayDate.getFullYear() + "-" + myBirthdayDate.getMonth() + "-" + myBirthdayDate.getDate()
    payLoad =
      name: me.first_name
      lastName: me.last_name
      email: me.email
      birthdate: birthday
      gender: me.gender
      verticalId: config.verticalId
      locale: me.locale
      facebookId: me.id
      facebookToken: me.id

    #$.fancybox.close()
    console.log "Enviando info al back"
    $.ajax config.apiUrl + "/affiliation/facebook",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(payLoad)
      xhrFields:
        withCredentials: true

      headers:
        "Accept-Language": "es"

      success: (data) ->
        console.log "facebook.json success!"
        console.log ["data", data]
        that.applyLogin data.response
        if 201 is data.meta.status
          console.log "Facebook registered"
          that.publishEvent("setRegisterFb", data.response.profile)
          that.publishEvent "showCompletaRegister", data.response.profile


      error: (xhr, textStatus, errorThrown) ->
        console.log "facebook.json error!"
        error = JSON.parse(xhr.responseText)
        alert error.meta.message

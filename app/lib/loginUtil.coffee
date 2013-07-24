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
          that.publishEvent 'applyLogin', data.response

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
    console.log ["LoginUtil#applyLogin",profile]
    if profile.apiToken
      mediator.flags.loggedIn = true
      mediator.profile.bitsBalance = profile.bitsBalance

      token.saveApiToken profile.apiToken

      profileData = profile.profile

      facebook = (item for item in profile.socialAccounts when item.providerId is "facebook") #profile.socialAccounts[0].providerId
      twitter = (item for item in profile.socialAccounts when item.providerId is "twitter")
      profileData.facebook = if facebook != null && facebook.length > 0  then "On" else "Off"
      profileData.twitter = if twitter != null && twitter.length > 0 then "On" else "Off"

      #Winbits.restoreCart $
      @publishEvent "showHeaderLogin"
      @publishEvent "restoreCart"
      @publishEvent "setProfile", profileData
      @publishEvent "setSubscription", subscriptions:profile.subscriptions
      @publishEvent "setAddress",  profile.mainShippingAddres

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
    $ = Backbone.$
    that = @
    myBirthdayDate = new Date(me.birthday)
    birthday = myBirthdayDate.getFullYear() + "-" + myBirthdayDate.getMonth() + "-" + myBirthdayDate.getDate()
    accessToken = mediator.facebook.accessToken
    profileUrl = "http://facebook.com/profile.php?id=" + me.id
    imageUrl = "http://graph.facebook.com/" + me.id + "/picture"

    payLoad =
      name: me.first_name
      lastName: me.last_name
      email: me.email
      birthdate: birthday
      gender: me.gender
      verticalId: config.verticalId
      locale: me.locale
      providerUserId: me.id
      facebookToken: accessToken
      profileUrl: profileUrl
      imageUrl: imageUrl

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
        that.publishEvent 'applyLogin', data.response
        if 201 is data.meta.status
          console.log ["Facebook registered", data.response.profile]
          that.publishEvent("setRegisterFb", data.response.profile)
          that.publishEvent "showCompletaRegister", data.response.profile


      error: (xhr, textStatus, errorThrown) ->
        console.log "facebook.json error!"
        error = JSON.parse(xhr.responseText)
        alert error.meta.message

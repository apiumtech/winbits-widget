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

  expressLogin : (token) ->
    console.log "Doing express login"
    console.log "LoginUtil#expressLogin"
    apiToken = if token? then token else util.retrieveKey(config.apiTokenName)
    that = @
    if apiToken and apiToken isnt "undefined"
      util.ajaxRequest( config.apiUrl + "/users/express-login.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(apiToken: apiToken)
        headers:
          "Accept-Language": "es"
        xhrFields:
          withCredentials: true
        success: (data) ->
          console.log "express-login.json Success!"
          that.publishEvent 'applyLogin', data.response
          if token? and data.response.profile?
            that.publishEvent 'setRegisterFb', data.response.profile
            that.publishEvent "showCompletaRegister", data.response
          else
            console.log('Ommiting Express Facebook Login...')
#            that.expressFacebookLogin Winbits.$

        error: (xhr) ->
          console.log "express-login.json Error!"
          util.showAjaxError(xhr.responseText)
      )
    else
      console.log('Ommiting Express Facebook Login...')
#      @expressFacebookLogin Winbits.$

  expressFacebookLogin : ($) ->
    console.log "Trying to login with facebook"
    that = @
    Winbits.rpc.facebookStatus (response) ->
      that.publishEvent 'facebookStatusHandler', response

  applyLogin : (profile) ->
    console.log ["LoginUtil#applyLogin",profile]
    if profile.apiToken
      mediator.flags.loggedIn = true
      mediator.profile.bitsBalance = profile.bitsBalance
      mediator.profile.socialAccounts = profile.socialAccounts
      mediator.profile.userId = profile.id
      mediator.global.profile = profile

      token.saveApiToken profile.apiToken

      profileData = profile.profile

      facebook = (item for item in profile.socialAccounts when item.providerId is "facebook" and item.available)
      twitter = (item for item in profile.socialAccounts when item.providerId is "twitter" and item.available)
      profileData.facebook = if facebook != null && facebook.length > 0  then "On" else "Off"
      profileData.twitter = if twitter != null && twitter.length > 0 then "On" else "Off"

      Winbits.$('#wbi-user-waiting-list-count').text profileData.waitingListCount
      Winbits.$('#wbi-user-waiting-list-count').text profileData.wishListCount
      Winbits.$('#wbi-user-pending-orders-count').text profileData.pendingOrdersCount

      @publishEvent "showHeaderLogin"
      @publishEvent "restoreCart"
      @publishEvent "setProfile", profileData
      subscriptionsModel = { subscriptions: profile.subscriptions, newsletterFormat: profileData.newsletterFormat, newsletterPeriodicity: profileData.newsletterPeriodicity }
      @publishEvent "setSubscription", subscriptionsModel
      @publishEvent "setAddress",  profile.mainShippingAddres

      $ = window.$ or Winbits.$
      $('#' + config.winbitsDivId).trigger 'loggedin', [profile]

  initLogout : () ->
    that = this
    console.log "initLogout"
    util.ajaxRequest( config.apiUrl + "/users/logout.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      xhrFields:
        withCredentials: true
      headers:
        "Accept-Language": "es"
      success: (data) ->
        that.applyLogout data.response
      error: (xhr) ->
        util.showAjaxError(xhr.responseText)
      complete: ->
        console.log "logout.json Completed!"
    )

  applyLogout : (logoutData) ->
    Winbits.rpc.logout(mediator.flags.fbConnect)
    util.deleteKey config.apiTokenName
    @publishEvent "resetComponents"
    @publishEvent "showHeaderLogout"
    @publishEvent "loggedOut"
    mediator.flags.loggedIn = false
    mediator.flags.fbConnect = false
    util.backToSite()
    $ = window.$ or Winbits.$
    $('#' + config.winbitsDivId).trigger 'loggedout', [logoutData]

  loginFacebook : (me) ->
    $ = Winbits.$
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

    util.ajaxRequest( config.apiUrl + "/users/facebook",
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
        that.publishEvent 'applyLogin', data.response
        if 201 is data.meta.status
          console.log ["Facebook registered", data.response.profile]
          that.publishEvent("setRegisterFb", data.response.profile)
          that.publishEvent "showCompletaRegister", data.response.profile
      error: (xhr) ->
        console.log "facebook.json error!"
        util.showAjaxError(xhr.responseText)
    )
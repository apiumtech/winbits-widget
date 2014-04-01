utils = require 'lib/utils'
token = require 'lib/token'

module.exports = class LoginUtil
  constructor:()->
    @.initialize.apply this, arguments
    console.log "LoginUtil#constructor"

  initialize: ->
    @subscribeEvent 'applyLogin', @applyLogin
    @subscribeEvent 'initLogout', @initLogout

#  applyLogin : (profile) ->
#    console.log ["LoginUtil#applyLogin",profile]
#    if profile.apiToken
#      mediator.flags.loggedIn = true
#      mediator.profile.bitsBalance = profile.bitsBalance
#      mediator.profile.socialAccounts = profile.socialAccounts
#      mediator.profile.userId = profile.id
#      mediator.global.profile = profile
#
#      token.saveApiToken profile.apiToken
#
#      profileData = profile.profile
#
#      facebook = (item for item in profile.socialAccounts when item.providerId is "facebook" and item.available)
#      twitter = (item for item in profile.socialAccounts when item.providerId is "twitter" and item.available)
#      profileData.facebook = if facebook != null && facebook.length > 0 then "On" else "Off"
#      profileData.twitter = if twitter != null && twitter.length > 0 then "On" else "Off"
#
#      Winbits.$('#wbi-user-waiting-list-count').text profileData.waitingListCount
#      Winbits.$('#wbi-user-wish-list-count').text profileData.wishListCount
#      Winbits.$('#wbi-user-pending-orders-count').text profileData.pendingOrdersCount
#
#      @publishEvent "showHeaderLogin"
#      @publishEvent "restoreCart"
#      @publishEvent "setProfile", profileData
#      subscriptionsModel = { subscriptions: profile.subscriptions, newsletterFormat: profileData.newsletterFormat, newsletterPeriodicity: profileData.newsletterPeriodicity }
#      @publishEvent "setSubscription", subscriptionsModel
#      @publishEvent "setAddress", profile.mainShippingAddres
#
#      $ = window.$ or Winbits.$
#      $('#' + config.winbitsDivId).trigger 'loggedin', [profile]

  initLogout : () ->
    console.log "initLogout"
    util.ajaxRequest( config.apiUrl + "/users/logout.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      headers:
        "Accept-Language": "es"
#        "WB-Api-Token": util.retrieveKey(config.apiTokenName)
      success: (data) ->
         utils.redirectToNotLoggedInHome()
#        that.applyLogout data.response
      error: (xhr) ->
        utils.showAjaxError(xhr.responseText)
      complete: ->
        console.log "logout.json Completed!"
    )

#  applyLogout : (logoutData) ->
#    Winbits.rpc.logout(mediator.flags.fbConnect)
#    util.deleteKey config.apiTokenName
#    @publishEvent "resetComponents"
#    @publishEvent "showHeaderLogout"
#    @publishEvent "loggedOut"
#    mediator.flags.loggedIn = false
#    mediator.flags.fbConnect = false
#    util.backToSite()
#    $ = window.$ or Winbits.$
#    Winbits.$('#wbi-div-switch-user').hide()
#    $('#' + config.winbitsDivId).trigger 'loggedout', [logoutData]


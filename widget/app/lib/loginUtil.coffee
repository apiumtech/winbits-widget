utils = require 'lib/utils'
token = require 'lib/token'
config = require 'config'
mediator = Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class LoginUtil
  constructor:()->
    @.initialize.apply this, arguments
    console.log "LoginUtil#constructor"

  initialize: ->
      super

  applyLogin : (profile) ->
    console.log ["LoginUtil#applyLogin",profile]
    if profile.apiToken
      token.saveApiToken profile.apiToken

      mediator.flags.loggedIn = true
      mediator.profile.bitsBalance = profile.bitsBalance
      mediator.profile.socialAccounts = profile.socialAccounts
      mediator.profile.userId = profile.id
      mediator.global.profile = profile


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
    utils.ajaxRequest( env.get('api-url') + "/users/logout.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": utils.retrieveKey(config.apiTokenName)
      success: @doLogoutSuccess
      error: @doLogoutError
      complete: ->
        console.log "logout.json Completed!"
    )

  doLogoutSuccess:  ->
    @applyLogout data.response
    utils.redirectToNotLoggedInHome()

  doLogoutError: (xhr)->
    #todo checar flujo si falla logout
    console.log ['Logout Error ',xhr.responseText]

  applyLogout : (logoutData) ->
    Winbits.rpc.logout(mediator.flags.fbConnect)
    utils.deleteKey config.apiTokenName
#    @publishEvent "resetComponents"
#    @publishEvent "showHeaderLogout"
#    @publishEvent "loggedOut"
    mediator.flags.loggedIn = false
    mediator.flags.fbConnect = false
#    $ = window.$ or Winbits.$
#    Winbits.$('#wbi-div-switch-user').hide()
#    $('#' + config.winbitsDivId).trigger 'loggedout', [logoutData]


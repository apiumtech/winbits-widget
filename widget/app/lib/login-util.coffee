utils = require 'lib/utils'
token = require 'lib/token'
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

     utils.saveApiToken profile.apiToken
     mediator.data.get('flags').loggedIn = true
     mediator.data.set 'profile', profile

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


  applyLogout : ->
    localStorage.clear()
    mediator.data.clear()
    mediator.data.get('rpc').logout ->
      console.log 'Winbits logout success :)'
    , -> console.log 'Winbits logout error D:'

    #    Winbits.rpc.logout(mediator.flags.fbConnect)
#    @publishEvent "resetComponents"
#    @publishEvent "showHeaderLogout"
#    @publishEvent "loggedOut"
#    $ = window.$ or Winbits.$
#    Winbits.$('#wbi-div-switch-user').hide()
#    $('#' + config.winbitsDivId).trigger 'loggedout', [logoutData]



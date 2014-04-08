utils = require 'lib/utils'
token = require 'lib/token'
mediator = Chaplin.mediator
$ = Winbits.$
_ = Winbits._
env = Winbits.env

loginUtils = {}
_(loginUtils).extend
  applyLogin : (loginData) ->
    mediator.data.set 'login-data', loginData
    utils.saveApiToken loginData.apiToken
    Winbits.trigger 'loggedin', [_.clone loginData]

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


  applyLogout: (logoutData) ->
    localStorage.clear()
    mediator.data.clear()
    Winbits.env.get('rpc').logout ->
      console.log 'Winbits logout success :)'
    , -> console.log 'Winbits logout error D:'
    Winbits.trigger 'loggedout', [logoutData]
    utils.redirectToNotLoggedInHome()

    #    Winbits.rpc.logout(mediator.flags.fbConnect)
#    @publishEvent "resetComponents"
#    @publishEvent "showHeaderLogout"
#    @publishEvent "loggedOut"
#    $ = window.$ or Winbits.$
#    Winbits.$('#wbi-div-switch-user').hide()
#    $('#' + config.winbitsDivId).trigger 'loggedout', [logoutData]


# Prevent creating new properties and stuff.
Object.seal? loginUtils

module.exports = loginUtils

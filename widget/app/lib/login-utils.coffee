'use strict'

utils = require 'lib/utils'
trackingUtils = require 'lib/tracking-utils'
mediator = Chaplin.mediator
$ = Winbits.$
_ = Winbits._
env = Winbits.env

loginUtils = {}
_(loginUtils).extend
  applyLogin : (loginData) ->
    mediator.data.set 'login-data', loginData
    utils.saveApiToken loginData.apiToken
    trackingUtils.deleteUTMs()
    Winbits.trigger 'loggedin', [_.clone loginData]

  applyLogout: (logoutData) ->
    if( utils.hasLocalStorage() )
      localStorage.clear()
    else
      utils.deleteApiToken()
    mediator.data.clear()
    Winbits.env.get('rpc').logout ->
      console.log 'Winbits logout success :)'
    , -> console.log 'Winbits logout error D:'
    utils.redirectToNotLoggedInHome()
    Winbits.trigger 'loggedout', [logoutData]

  doLogoutSuccess: (data) ->
    @applyLogout(data.response)

  doLogoutError: (xhr)->
    # TODO checar flujo si falla logout
    @applyLogout()

  requestResendConfirmationMail:(confirmURL)->
    defaults =
      dataType: "json"
      headers:
        "Accept-Language": "es"
    utils.ajaxRequest(
      utils.getResourceURL(confirmURL),defaults)

# Prevent creating new properties and stuff.
Object.seal? loginUtils

module.exports = loginUtils

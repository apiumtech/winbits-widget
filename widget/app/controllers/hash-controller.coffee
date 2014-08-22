'use strict'

Controller = require 'controllers/base/controller'
utils = require 'lib/utils'
trackingUtils = require 'lib/tracking-utils'
$ = Winbits.$
promises = []
mediator = Winbits.Chaplin.mediator

module.exports = class HashController extends Controller

  completeRegister: (obj)->
    @expressLogin(obj.apiToken, yes)
      .done @completeRegisterSuccess
      .fail @expressLoginError

  switchUser: (obj)->
    @expressLogin(obj.apiToken)
      .done @switchUserSuccess
      .fail @expressLoginError

  expressLogin : (apiToken, firstLogin = no) ->
    requestData =
      apiToken: apiToken
      firstLogin: firstLogin
      utms: trackingUtils.getUTMs()
    utils.ajaxRequest Winbits.env.get('api-url') + '/users/express-login.json',
      type: 'POST',
      dataType: "json"
      context: @
      data: JSON.stringify(requestData)

  completeRegisterSuccess: (data) ->
    if $.isEmptyObject data.response
      @expressLoginError()
    else
      @saveLoginData data.response
      utils.redirectTo controller:'complete-register', action:'index'

  switchUserSuccess: (data) ->
    if $.isEmptyObject data.response
      utils.redirectTo controller: 'home', action: 'index'
    else
      @saveLoginData data.response
      utils.redirectToLoggedInHome()

  saveLoginData: (loginData)->
    utils.deleteApiToken()
    utils.saveLoginData loginData
    mediator.data.set 'login-data', loginData
    trackingUtils.deleteUTMs()

  expressLoginError: () ->
    utils.redirectTo controller: 'home', action: 'index'

  resetPassword:(params) ->
    mediator.data.set('salt', params)
    utils.redirectTo controller:'reset-password', action: 'index'

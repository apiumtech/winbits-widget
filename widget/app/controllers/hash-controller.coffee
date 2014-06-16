'use strict'
Controller = require 'controllers/not-logged-in-controller'
$ = Winbits.$
utils = require 'lib/utils'
promises = []
mediator = Winbits.Chaplin.mediator

module.exports = class HashController extends Controller

  completeRegister: (obj)->
    @expressLogin(obj.apiToken)
      .done @completeRegisterSuccess
      .fail @expressLoginError

  switchUser: (obj)->
      @expressLogin(obj.apiToken)
        .done @switchUserSuccess
        .fail @expressLoginError


  expressLogin : (apiToken) ->
    utils.ajaxRequest Winbits.env.get('api-url') + '/users/express-login.json',
      type: 'POST',
      dataType: "json"
      data: JSON.stringify(apiToken: apiToken)

  completeRegisterSuccess: (data) ->
    if $.isEmptyObject data.response
      @expressLoginError()
    else
      utils.saveLoginData data.response
      mediator.data.set 'login-data', data.response
      utils.redirectTo controller:'complete-register', action:'index'

  switchUserSuccess: (data) ->
    if $.isEmptyObject data.response
      utils.redirectTo controller: 'home', action: 'index'
    else
      utils.saveLoginData data.response
      mediator.data.set 'login-data', data.response
      utils.redirectToLoggedInHome()

  expressLoginError: () ->
    utils.redirectTo controller: 'home', action: 'index'

  resetPassword:(params) ->
    utils.redirectTo controller:'reset-password' ,action: 'index', params: params


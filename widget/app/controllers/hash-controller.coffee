Controller = require 'controllers/not-logged-in-controller'
$ = Winbits.$
utils = require 'lib/utils'
promises = []

module.exports = class HashController extends Controller

  completeRegister: (obj)->
    console.log ['completeRegister', obj.apiToken]
    @expressLogin(obj.apiToken)
      .done @expressLoginSuccess
      .fail @expressLoginError

  expressLogin : (apiToken) ->
    utils.ajaxRequest Winbits.env.get('api-url') + '/users/express-login.json',
      type: 'POST',
      data: apiToken: apiToken

  expressLoginSuccess: (data) ->
    console.log 'Login data verified :)'
    if $.isEmptyObject data.response
      @expressLoginError()
    else
      console.log 'valid token'
      utils.saveLoginData data.response
      utils.redirectTo controller:'complete-register', action:'index'

  expressLoginError: () ->
    utils.redirectToNotLoggedInHome()

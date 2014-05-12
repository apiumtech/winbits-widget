'use strict'
View = require 'views/base/view'
loginUtils = require 'lib/login-utils'
utils = require 'lib/utils'
$ = Winbits.$
env = Winbits.env

module.exports = class SwitchUserView extends View
  container: '#wbi-header-wrapper'
  id: 'wbi-switch-user-div'
  className: 'switchUser'
  template: require './templates/switch-user'

  initialize: ->
    super
    @delegate 'click', '.wbc-logout', @doLogout

  doLogout: ->
    @model.requestLogout()
    .done(@doLogoutSuccess)
    .fail(@doLogoutError)

  doLogoutSuccess: (data) ->
    loginUtils.doLogoutSuccess(data.response)

  doLogoutError: (xhr)->
    loginUtils.doLogoutError(xhr)

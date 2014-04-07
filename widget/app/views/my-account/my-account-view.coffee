View = require 'views/base/view'
utils = require 'lib/utils'
loginUtil = require 'lib/login-utils'
$ = Winbits.$
env = Winbits.env

module.exports = class MyAccountView extends View
  container: '#wbi-my-account-container'
  id: 'wbi-my-account-div'
  className: 'dropMenu miCuentaDiv'
  attributes:
    style: "display: none;"
  template: require './templates/my-account'

  initialize: ->
    console.log "my-account"
    @delegate 'click', '#wbi-my-account-logout-btn', @doLogout
    super

  attach: ->
    super
    @$el.prev('.spanDropMenu').dropMainMenu()

  doLogout: ->
    @model.requestLogout()
     .done(@doLogoutSuccess)
     .fail(@doLogoutError)

  doLogoutSuccess: (data) ->
    loginUtil.applyLogout(data.response)

  doLogoutError: (xhr)->
    #todo checar flujo si falla logout
    console.log ['Logout Error ',xhr.responseText]
    loginUtil.applyLogout()


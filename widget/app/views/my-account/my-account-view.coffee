'use strict'

View = require 'views/base/view'
MyAccount = require 'models/my-account/my-account'
utils = require 'lib/utils'
loginUtils = require 'lib/login-utils'
$ = Winbits.$
env = Winbits.env

module.exports = class MyAccountView extends View
  container: '#wbi-my-account-container'
  id: 'wbi-my-account-div'
  className: 'dropMenu miCuentaDiv'
  attributes:
    style: "display: none;"
  template: require './templates/my-account'
  model: new MyAccount

  initialize: ->
    super
    @delegate 'click', '#wbi-my-account-close', @clickClose

  attach: ->
    super
    @$el.prev().dropMainMenu()
    @$('.miCuenta-linktabs').tabs({ tabClass: '.miCuenta-tab'});
    @$('#wbi-my-account-logout-btn').click $.proxy @doLogout, @

  doLogout: ->
    @model.requestLogout()
     .done(@doLogoutSuccess)
     .fail(@doLogoutError)

  doLogoutSuccess: (data) ->
    loginUtils.doLogoutSuccess(data)

  doLogoutError: (xhr)->
    loginUtils.doLogoutError(xhr)

  clickClose: ->
    @$el.prev().slideUp()

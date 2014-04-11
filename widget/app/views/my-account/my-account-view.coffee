View = require 'views/base/view'
MyAccount = require 'models/my-account/my-account'
utils = require 'lib/utils'
loginUtil = require 'lib/login-utils'
$ = Winbits.$
env = Winbits.env

module.exports = class MyAccountView extends View
  container: '#wbi-my-account-container'
  id: 'wbi-my-account-div'
  className: 'dropMenu miCuentaDiv'
  autoRender: yes
  autoAttach: yes
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
    @$('#wbi-my-account-logout-btn').click $.proxy @doLogout, @

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

  clickClose: ->
    @$el.prev().slideUp()

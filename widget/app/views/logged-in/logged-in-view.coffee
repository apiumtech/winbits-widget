View = require 'views/base/view'
utils = require 'lib/utils'
loginUtil = require 'lib/login-utils'
$ = Winbits.$
env = Winbits.env


module.exports = class LoggedInView extends View
  container: '#wbi-header-wrapper'
  className: 'miCuenta'
  autoRender: true
  template: require './templates/logged-in'

  initialize: ->
    @listenTo @model, 'change', @render
    @delegate 'click', '.spanDropMenu', @clickOpenOrClose
    @delegate 'click', '.miCuenta-logout', @doLogout
    @delegate 'click', '.miCuenta-close', @clickClose

  clickOpenOrClose: ->
    $divMiCuenta = @$('.miCuentaDiv')
    if $divMiCuenta.is(':hidden')
      $divMiCuenta.slideDown()
    else
      $divMiCuenta.slideUp()

  clickClose: ->
      @$('.miCuentaDiv').slideUp()

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

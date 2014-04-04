View = require 'views/base/view'
utils = require 'lib/utils'
loginUtil = require 'lib/login-util'
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
    console.log "initLogout"
    utils.ajaxRequest( env.get('api-url') + "/users/logout.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": utils.getApiToken
      success: @doLogoutSuccess
      error: @doLogoutError
      complete: ->
        console.log "logout.json Completed!"
    )

  doLogoutSuccess:  ->
      loginUtil.applyLogout()
      utils.deleteApiToken (data.response.apiToken)
      mediator.data.get('flags').loggedIn = false
      mediator.data.get('flags').fbConnect = false
      utils.redirectToNotLoggedInHome()

  doLogoutError: (xhr)->
    #todo checar flujo si falla logout
    console.log ['Logout Error ',xhr.responseText]


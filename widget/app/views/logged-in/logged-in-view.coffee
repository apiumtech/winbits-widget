View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$
env = Winbits.env


module.exports = class LoggedInView extends View
  container: '#wbi-header-wrapper'
  className: 'miCuenta'
  autoRender: true
  template: require './templates/logged-in'

  initialize: ->
    @listenTo @model, 'change', @render
    @storeApiToken(@model.attributes.apiToken)
    @delegate 'click', '.spanDropMenu', @clickOpen
    @delegate 'click', '.miCuenta-logout', @doLogout
    @delegate 'click', '.miCuenta-close', @clickClose

  storeApiToken: (apiToken)->
    utils.storeKey('apiToken', apiToken)


  clickOpen: ->
      @$('.miCuentaDiv').slideDown()

  clickClose: ->
      @$('.miCuentaDiv').slideUp()

  doLogout: ->
    that = this
    console.log "initLogout"
    utils.ajaxRequest( env.get('api-url') + "/users/logout.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": utils.retrieveKey('apiToken')
      success: @doLogoutSuccess
      error: @doLogoutError
      complete: ->
        console.log "logout.json Completed!"
    )

  doLogoutSuccess:  ->
    utils.deleteKey('apiToken')
    utils.redirectToNotLoggedInHome()

  doLogoutError: (xhr)->
    console.log ['Logout Error ',xhr.responseText ]


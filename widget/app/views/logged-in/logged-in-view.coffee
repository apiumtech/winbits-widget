View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$
env = Winbits.env
mediator = Winbits.Chaplin.mediator
MyAccountView = require 'views/my-account/my-account-view'

module.exports = class LoggedInView extends View
  container: '#wbi-header-wrapper'
  className: 'miCuenta'
  autoRender: true
  template: require './templates/logged-in'

  initialize: ->
    @listenTo @model, 'change', @render
    @storeApiToken(@model.attributes.apiToken)
    @delegate 'click', '.miCuenta-logout', @doLogout
    @delegate 'click', '.miCuenta-close', @clickClose


  attach: ->
    super
    myAccountView = new MyAccountView
    @subview 'myAccountSubview', myAccountView
    console.log [mediator.data.get "action-my-account"]

  storeApiToken: (apiToken)->
    utils.storeKey('apiToken', apiToken)



  clickOpenOrClose: ->
    $divMiCuenta = @$('.miCuentaDiv')
    if $divMiCuenta.is(':hidden')
#      redirectTo = @$('#wbi-route-my-account').val()+'#'+@$('#wbi-action-my-account').val()
#      console.log ["redirectTo", redirectTo]
#      utils.redirectTo redirectTo
      $divMiCuenta.slideDown()
    else
      $divMiCuenta.slideUp()

  clickClose: ->
      @$('.miCuentaDiv').slideUp()

  doLogout: ->
    that =
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


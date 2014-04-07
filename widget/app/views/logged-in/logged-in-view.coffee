View = require 'views/base/view'
utils = require 'lib/utils'
loginUtil = require 'lib/login-utils'
$ = Winbits.$
env = Winbits.env
mediator = Winbits.Chaplin.mediator


module.exports = class LoggedInView extends View
  container: '#wbi-header-wrapper'
  className: 'miCuenta'
  autoRender: true
  template: require './templates/logged-in'

  initialize: ->
    @listenTo @model, 'change', @render
    @delegate 'click', '.miCuenta-close', @clickClose


  attach: ->
    super
    console.log [mediator.data.get, "action-my-account"]

  clickClose: ->
    @$('.miCuentaDiv').slideUp()



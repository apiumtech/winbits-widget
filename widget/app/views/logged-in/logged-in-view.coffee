View = require 'views/base/view'
utils = require 'lib/utils'
loginUtil = require 'lib/login-utils'
$ = Winbits.$
env = Winbits.env
mediator = Winbits.Chaplin.mediator


module.exports = class LoggedInView extends View
  container: '#wbi-header-wrapper'
  className: 'miCuenta'
  template: require './templates/logged-in'

  initialize: ->
    super
    @listenTo @model, 'change', @render


  attach: ->
    super

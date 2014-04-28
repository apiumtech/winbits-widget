View = require 'views/base/view'
LoggedIn = require 'models/logged-in/logged-in'
utils = require 'lib/utils'
loginUtil = require 'lib/login-utils'
$ = Winbits.$
env = Winbits.env
mediator = Winbits.Chaplin.mediator

module.exports = class LoggedInView extends View
  container: '#wbi-header-wrapper'
  className: 'miCuenta'
  template: require './templates/logged-in'
  model: new LoggedIn mediator.data.get 'login-data'

  initialize: ->
    super
    @listenTo @model, 'change', @render

  attach: ->
    super
    @$('#wbi-my-account-link').one('click', ->
      mediator.data.set('tabs-swapped', yes)
    )
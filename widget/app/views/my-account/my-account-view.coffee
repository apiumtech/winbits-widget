View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$
env = Winbits.env

module.exports = class MyAccountView extends View
  container: '.miCuenta-tabs'
  template: require './templates/my-account'

  initialize: ->
    console.log "my-account"
    super
  #    @listenTo @model, 'change', @render
  #    @delegate 'click', '#wbi-login-in-btn', @doMyProfile

  attach: ->
    super

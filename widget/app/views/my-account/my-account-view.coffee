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

  attach: ->
    super

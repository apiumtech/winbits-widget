View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$
env = Winbits.env

module.exports = class MyAccountView extends View
  container: '#wbi-my-account-container'
  id: 'wbi-my-account-div'
  className: 'dropMenu miCuentaDiv'
  attributes:
    style: "display: none;"
  template: require './templates/my-account'

  initialize: ->
    console.log "my-account"
    super

  attach: ->
    super
    @$el.prev('.spanDropMenu').dropMainMenu()
#    @$el.parent().find('.spanDropMenu').dropMainMenu()

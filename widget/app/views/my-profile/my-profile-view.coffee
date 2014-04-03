View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$
env = Winbits.env

module.exports = class MyProfileView extends View
  container: '.wbc-my-account-container'
  id: 'wbi-my-profile'
  template: require './templates/my-profile'

  initialize: ->
    super
    @openMyAccount()

  attach: ->
    super

  openMyAccount: ->
    $('#wbi-route-my-account').val('my-profile2')
    $('#wbi-action-my-account').val('index2')
    $('.miCuentaDiv').slideDown()



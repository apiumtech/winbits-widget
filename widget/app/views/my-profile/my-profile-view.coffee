View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$
env = Winbits.env

module.exports = class MyProfileView extends View
  container: '.wbc-my-account-container'
  template: require './templates/my-profile'

  initialize: ->
    super
    @openMyAccount()
    #    @listenTo @model, 'change', @render
#    @delegate 'click', '#wbi-login-in-btn', @doMyProfile

  attach: ->
    super

  openMyAccount: ->
    $('.miCuentaDiv').slideDown()



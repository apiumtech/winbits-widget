View = require 'views/base/view'
utils = require 'lib/utils'
loginUtil = require 'lib/login-utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
_ = Winbits._
env = Winbits.env

module.exports = class LoginView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-coupons-modal'
  template: require './templates/coupons'

  initialize: ->
    super


  attach: ->
    super
    @showAsModal()

  showAsModal: ->
    $('<a>').wbfancybox(href: '#' + @id, onClosed: -> utils.redirectTo controller: 'home', action: 'index').click()

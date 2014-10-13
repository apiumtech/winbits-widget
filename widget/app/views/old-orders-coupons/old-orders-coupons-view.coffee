'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
_ = Winbits._
env = Winbits.env

module.exports = class OldOrdersCouponsView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-old-orders-coupons'
  template: require './templates/old-orders-coupons'

  initialize: ->
    super

  attach: ->
    super
    @showAsModal()


  showAsModal: ->
    $('<a>').wbfancybox(href: '#' + @id, onClosed: -> utils.redirectTo controller: 'home', action: 'index').click()


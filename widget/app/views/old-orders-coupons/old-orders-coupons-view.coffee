'use strict'
OldOrdersHistoryView = require 'views/old-orders-history/old-orders-history-view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
_ = Winbits._
env = Winbits.env

module.exports = class OldOrdersCouponsView extends OldOrdersHistoryView
  container: '#wbi-winbits-modals'
  id: 'wbi-old-orders-coupons'
  template: require './templates/old-orders-coupons'

  initialize: ->
    super

  attach: ->
    super
    @showAsModal()


  showAsModal: ->
    $('<a>').wbfancybox(href: '#' + @id, onClosed: -> utils.redirectTo controller: 'old-orders-history', action: 'index').click()


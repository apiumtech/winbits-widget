'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class ShippingOrderHistoryTableSubView extends View
  container: '#wbi-shipping-order-history-table-div'
  template: require './templates/shipping-order-history-table'


  initialize:()->
    super
    @listenTo @model,  'change', -> @render()

  attach: ->
    super
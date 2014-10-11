'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class OldOrdersHistoryView extends View
  container: env.get('vertical-container')
  className: 'widgetWinbitsMain wbc-vertical-content'
  template: require './templates/old-orders-history'
  params:
    max:10

  initialize:()->
    super
    $('#wbi-my-account-div').slideUp()
    @delegate 'click', '#wbi-shipping-order-link', @redirectToShippingOrderHistory
    @delegate 'click', '#wbi-shipping-order-link-text', @redirectToShippingOrderHistory
    @delegate 'click', '#wbi-old-orders-history-btn-back', @backToVertical
    utils.replaceVerticalContent('.widgetWinbitsMain')

  attach: ->
    super
    console.log ["MODEL IN OLD ORDERS", @model]
    @$('.select').customSelect()
      .wbpaginator(total: @model.getTotal(), max: @params.max, change: $.proxy(@pageChanged, @))

  redirectToShippingOrderHistory: (e)->
    e.preventDefault()
    utils.redirectTo(controller: 'shipping-order-history')

  backToVertical:(e)->
    utils.restoreVerticalContent('.widgetWinbitsMain')
    utils.redirectToLoggedInHome()
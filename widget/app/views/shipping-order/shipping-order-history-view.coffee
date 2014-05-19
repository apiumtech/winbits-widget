'use strict'

View = require 'views/base/view'
ShippingOrderSubview = require 'views/shipping-order/shipping-order-history-table-subview'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class ShippingOrderHistoryView extends View
  container: 'main'
  className: 'widgetWinbitsMain'
  template: require './templates/shipping-order-history'


  initialize:()->
    super
    @model.fetch()
    @delegate 'click', '#wbi-shipping-order-history-btn-back', @backToVertical
    $('#wbi-my-account-div').slideUp()
    $('main .wrapper').hide()
    @model.fetch(success: $.proxy(@successFetch, @))

  attach: ->
    super
    @$('.select').customSelect()

  backToVertical:()->
    $('main .wrapper').show()
    utils.redirectToLoggedInHome()

  render: ()->
    super
    @subview 'shipping-order-history-table', new ShippingOrderSubview model:@model

  successFetch: (data)->
    @render()
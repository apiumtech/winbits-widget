'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
_ = Winbits._
env = Winbits.env

module.exports = class CheckOutTempTotalSubView extends View
  template: require './templates/checkout-temp-order-details'


  initialize:()->
    super

  attach: ->
    super
    @$('.wbc-item-quantity').customSelect()
    .on("change", $.proxy(@doUpdateQuantity, @))

  doUpdateQuantity: (e) ->
    e.preventDefault()
    $itemsTotal = 0
    itemChange = no
    quantity = @$(e.currentTarget)
    $parseQuantity = parseInt quantity.find('option:selected').val()
    itemId = quantity.closest('tr').data('id')
    $orderDetails = _.clone @model.get('orderDetails')
    for orderDetail in $orderDetails
      if orderDetail.id is itemId and orderDetail.quantity != $parseQuantity
        itemChange = yes
        $itemsTotal = orderDetail.amount
        orderDetail.quantity = $parseQuantity
        orderDetail.amount = orderDetail.sku.price * orderDetail.quantity
        $itemsTotal -= orderDetail.amount
    if itemChange
      @model.set 'orderDetails', $orderDetails
      @model.set 'itemsTotal', (@model.get('itemsTotal') - $itemsTotal)
      $total = (@model.get('total') - $itemsTotal)
      $bitsTotal = if $total <= @model.attributes.bitsTotal then $total else @model.attributes.bitsTotal
      @model.set 'bitsTotal', $bitsTotal
      @model.set 'total', $total
      @render()




'use strict'

View = require 'views/base/view'
CheckoutTempSubview = require 'views/checkout-temp/checkout-temp-table-subview'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class CheckoutTempView extends View
  container: 'main'
  className: 'widgetWinbitsMain'
  template: require './templates/checkout-temp'


  initialize:()->
    super
    $('main .wrapper').hide()

  attach: ->
    super


  backToVertical:()->
    $('main .wrapper').show()
    utils.redirectToLoggedInHome()

  render: ()->
    super
    @subview 'checkout-temp-table', new CheckoutTempSubview model:@model


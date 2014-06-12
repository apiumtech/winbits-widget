'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
_ = Winbits._
env = Winbits.env

module.exports = class CheckoutTempView extends View
  container: 'main'
  className: 'widgetWinbitsMain'
  template: require './templates/checkout-temp'


  initialize:()->
    super
    @delegate 'click', '#wbi-return-site-btn', @backToVertical
    @delegate 'click', '#wbi-post-checkout-btn', @doToCheckout
    $('main .wrapper').hide()

  attach: ->
    super

  backToVertical: ->
    $('main .wrapper').show()
    utils.redirectToLoggedInHome()

  doToCheckout: ->
    order = _.clone @model.attributes
    @model.postToCheckoutApp(order)



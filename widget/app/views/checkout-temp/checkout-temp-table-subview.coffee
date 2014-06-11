'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class CheckoutTempTableSubView extends View
  container: '.resumeCheckoutTable'
  template: require './templates/checkout-temp-table'


  initialize:()->
    super
    console.log['ENTRE SUB VIEW']
#    @listenTo @model,  'change', -> @render()

  attach: ->
    super
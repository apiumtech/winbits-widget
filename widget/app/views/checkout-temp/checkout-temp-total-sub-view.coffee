'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class CheckOutTempTotalSubView extends View
  template: require './templates/checkout-temp-total'

  initialize:()->
    super
    @listenTo @model,  'change:total', -> @render()
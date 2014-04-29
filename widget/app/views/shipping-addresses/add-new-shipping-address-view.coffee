'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class AddNewShippingAddressView extends View
  container: '#wbi-shipping-new-address-container'
  template: require './templates/add-new-shipping-address'
  noWrap: yes

  initialize: ->
    super
    console.log ["add-new shipping address renderezing"]

  attach: ->
    super
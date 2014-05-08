'use strict'

View = require 'views/base/view'
$ = Winbits.$

module.exports = class NewCardView extends View
  container: '#wb-credit-cards'
  id: 'wbi-new-card-view'
  className: 'creditCardNew'
  template: require './templates/new-card'

'use strict'

View = require 'views/base/view'
$ = Winbits.$

module.exports = class NewCardView extends View
  container: '#wb-credit-cards'
  id: 'wbi-new-card-view'
  className: 'creditcardNew'
  template: require './templates/new-card'

  initialize: ->
    super

  attach: ->
    super
    @$('.wbc-country-field').customSelect()
    @$('[name=cardPrincipal]').parent().customCheckbox()

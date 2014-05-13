'use strict'

CardView = require 'views/cards/card-view'
utils = require 'lib/utils'
$ = Winbits.$

module.exports = class EditCardView extends CardView
  id: 'wbi-edit-card-view'

  initialize: ->
    super
    # @delegate 'click', '#wbi-save-card-btn', @saveNewCard

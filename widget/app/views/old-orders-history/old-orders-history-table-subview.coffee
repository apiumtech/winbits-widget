'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class OldsOrdersHistoryTableSubView extends View
  container: '#wbi-old-history-table'
  template: require './templates/old-orders-history-table'

  initialize:()->
    super
    @listenTo @model,  'change', -> @render()

  attach: ->
    super
    @$('.wbc-icon-download').toolTip()
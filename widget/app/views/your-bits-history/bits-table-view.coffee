'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class BitsTableView extends View
  container: '#wbi-bits-history-view'
  template: require './templates/your-bits-table-history'
  params:
    max: 20


  initialize:()->
    super
    @listenTo @model, 'change', @refreshHistory

  attach:()->
    super
    @$('.select').customSelect()
    @$('.wbc-paginator').wbpaginator(total: @model.getTotalTransactions(), max: @params.max, change: $.proxy(@pageChanged, @))

  refreshHistory: ->
    @render()
    @$('.wbc-paginator').wbpaginator('option', 'total', @model.getTotalTransactions())
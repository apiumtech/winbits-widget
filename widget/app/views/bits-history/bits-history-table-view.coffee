'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
env = Winbits.env
$ = Winbits.$

module.exports = class BitsHistoryTableView extends View
  container: '#wbi-bits-history-view'
  template: require './templates/bits-history-table'

  initialize:()->
    super
    @listenTo @model,  'change', @render

  attach:()->
    super

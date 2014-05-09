'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class MailingView extends View
  container: '#wb-mailing'
  template: require './templates/mailing'

  initialize: ->
    super
#    @listenTo @model,  'change', -> @render()

  attach: ->
    super
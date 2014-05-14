'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class HistoryView extends View
  container: 'main'
  className: 'widgetWinbitsMain'
  template: require './templates/your-bits-history'


  initialize:()->
    super
    @listenTo @model,  'change', -> @render()
    @model.fetch()
    @delegate 'click', '#wbi-your-bits-history-btn-back', @backToVertical
    $('#wbi-my-account-div').slideUp()
    $('main .wrapper').hide()

  attach: ->
    super
    @$('.select').customSelect()

  backToVertical:()->
    console.log ["MODEL YOUR BITS", @model]
    $('main .wrapper').show()
    utils.redirectToLoggedInHome()
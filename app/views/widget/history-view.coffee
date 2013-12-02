template = require 'views/templates/widget/history-view'
View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'
mediator = require 'chaplin/mediator'

module.exports = class HistoryView extends View
  autoRender: yes
  container: '#headerHistory'
  template: template

  render: ->
    super

  initialize: ->
    super
    @delegate 'click', '#bitsCredit', @showBitsRecord
    @delegate 'click', '#ordersHistory', @showOrdersRecord
    @delegate 'click', '#waitingListTable', @showWaitingList
    @delegate 'click', '#wishListTable', @showWishList

  showBitsRecord: (e)->
    e.preventDefault()
    @showAccordionPanel('bitsHistoryHId')

  showOrdersRecord: (e) ->
    e.preventDefault()
    @showAccordionPanel('ordersHistoryHId')

  showWaitingList: (e) ->
    e.preventDefault()
    @showAccordionPanel('waitingListHId')

  showWishList: (e) ->
    e.preventDefault()
    @showAccordionPanel('wishListHId')

  showAccordionPanel: (panelId)->
    @showHistoryView()
    Backbone.$(".accordeonWinbits").children('h2#' + panelId).click()

  showHistoryView: () ->
    $ = Backbone.$
    $main = $('main').first()
    $('div.dropMenu').slideUp()
    $historicalContainer = $main.find('div.wrapper.historical')
    $main.children().hide()
    $historicalContainer.find('h2').attr('class', '').find('.icon').removeClass('minusIcon')
    $historicalContainer.find('.accordeonContent').hide()
    $historicalContainer.parents().show()
    $historicalContainer.show()
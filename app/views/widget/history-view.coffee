template = require 'views/templates/widget/history-view'
View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'

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
    console.log "ENTRE A SHOWBITSRECORD"
    e.preventDefault()
    @showHistoryView()
    Backbone.$(".accordeonWinbits").find("h2")[1].click()

  showOrdersRecord: (e) ->
    e.preventDefault()
    @showHistoryView()
    Backbone.$(".accordeonWinbits").find("h2")[0].click()

  showWaitingList: (e) ->
    e.preventDefault()
    @showHistoryView()
    Backbone.$(".accordeonWinbits").find("h2")[2].click()

  showWishList: (e) ->
    e.preventDefault()
    @showHistoryView()
    Backbone.$(".accordeonWinbits").find("h2")[3].click()

  showHistoryView: () ->
    $ = Backbone.$
    $main = $('main').first()
    $('div.dropMenu').slideUp()
    $historicalContainer = $main.find('div.wrapper.historical')
    if $historicalContainer.css('display') is 'none'
      $historicalContainer.find('.accordeonContent').hide()
      $main.find('div.wrapper').hide()
      $historicalContainer.show()
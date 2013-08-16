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


  showBitsRecord: (e)->
    console.log "ENTRE A SHOWBITSRECORD"
    e.preventDefault()
    Backbone.$("#historicalAccordion").show()
    @publishEvent 'cleanAccordion'
    @publishEvent 'showHistorical'
    Backbone.$(".accordeonWinbits").find("h2")[1].click()



  showOrdersRecord: (e) ->
    console.log "ENTRE A SHOW ORDERS"
    e.preventDefault()
    Backbone.$("#historicalAccordion").show()
    @publishEvent 'cleanAccordion'
    @publishEvent 'showOrdersHistory'
    Backbone.$(".accordeonWinbits").find("h2")[0].click()

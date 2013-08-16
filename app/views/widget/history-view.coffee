template = require 'views/templates/widget/history-view'
View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'

module.exports = class HistoryView extends View
  autoRender: yes
  #className: 'home-page'
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
    Backbone.$("#historial").remove()
    Backbone.$("main:first").find("div").toggle()
    Backbone.$("main:first").append("<div id='historial' ></div>")
    @publishEvent 'showHistorical'

  showOrdersRecord: (e) ->
    console.log "ENTRE A SHOW ORDERS"
    e.preventDefault()
    Backbone.$("#historial").remove()
    Backbone.$("main:first").find("div").toggle()
    Backbone.$("main:first").append("<div id='historial' ></div>")
    @publishEvent 'showOrdersHistory'
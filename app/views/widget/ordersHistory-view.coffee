template = require 'views/templates/widget/account-history'
View = require 'views/base/view'
util = require 'lib/util'

module.exports = class OrdersHistoryView extends View
  autoRender: false
  #className: 'home-page'
  container: '#historial'
  template: template

  render: ->
    super

  initialize: ->
    super
    @delegate 'change', '.orderHistoryFilter', @filterOrderHistory
    @subscribeEvent 'orderRecordReady', @handlerModelReady

  attach: ->
    super
    #@delegate 'click', '.btnBackToSite', @backToSite
    util.accordeon
      obj: '.accordeonWinbits'
      trigger: 'h2'
      first: true # Si quieren que sea abra el primer elemento en la carga, poner TRUE
      claseActivo: 'activo'
      contenedor: '.accordeonContent'
      minusIcon: 'minusIcon'

    #window.w$(".accordeonWinbits").find("h2")[1].click()

  handlerModelReady: ->
    @render()

  backToSite: (e) ->
    console.log "ENTRE A BACKTOSITE"
    Backbone.$("#historial").remove()
    Backbone.$("main:first").find("div").toggle()
#Backbone.$("main:first").append("<div id='historial' ></div>")

  filterOrderHistory: (e) ->
    e.preventDefault()
    $form = @$el.find("#orderHistoryFilterForm")
    console.log ['form', $form]
    formData = util.serializeForm($form)
    console.log ['datos', formData]
    @publishEvent 'showOrdersHistory', formData


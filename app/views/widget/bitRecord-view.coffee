template = require 'views/templates/widget/bitsCredit'
View = require 'views/base/view'
util = require 'lib/util'

module.exports = class BitRecordView extends View
  autoRender: false
  #className: 'home-page'
  container: '#historial'
  template: template

  render: ->
    super

  initialize: ->
    super
    @subscribeEvent 'bitRecordReady', @handlerModelReady

  attach: ->
    super
    @delegate 'click', '.btnBackToSite', @backToSite
    util.accordeon
      obj: '.accordeonWinbits'
      trigger: 'h2'
      first: false # Si quieren que sea abra el primer elemento en la carga, poner TRUE
      claseActivo: 'activo'
      contenedor: '.accordeonContent'
      minusIcon: 'minusIcon'

    window.w$(".accordeonWinbits").find("h2")[1].click()

  handlerModelReady: ->
      @render()

  backToSite: (e) ->
    console.log "ENTRE A BACKTOSITE"
    Backbone.$("#historial").remove()
    Backbone.$("main:first").find("div").toggle()
    #Backbone.$("main:first").append("<div id='historial' ></div>")

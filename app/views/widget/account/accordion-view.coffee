template = require 'views/templates/account/accordion'
View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'
vendor = require 'lib/vendor'

module.exports = class AccordionView extends View
  autoRender: yes
  container: '.widgetWinbitsMain'
  template: template

  render: ->
    super

  initialize: ->
    super
    console.log 'Inicializando acordeon'
    @subscribeEvent 'cleanAccordion', @cleanAccordion
    @subscribeEvent 'renderAccordionOption', @renderAccordionOption
    @delegate 'click', '.btnBackToSite', @backToSite

  attach: ->
    super
    console.log 'attach acordeon'
    vendor.accordeon
      obj: '.accordeonWinbits'
      trigger: 'h2'
      first: false # Si quieren que sea abra el primer elemento en la carga, poner TRUE
      claseActivo: 'activo'
      contenedor: '.accordeonContent'
      minusIcon: 'minusIcon'

    console.log 'END Inicializando acordeon'

  backToSite: (e) ->
    util.backToSite(e)

  cleanAccordion:  ->
    console.log('Limpiando acordion')
    Backbone.$(".accordeonContent").hide()

  renderAccordionOption: (op)->
    console.log ['Option', op.attr("id")]
    optionId = op.attr("id")
    @publishEvent 'cleanAccordion'
    if optionId == 'ordersHistoryHId'
      @publishEvent 'showOrdersHistory'
      Backbone.$("#ordersHistoryContent").show()

    if optionId == 'bitsHistoryHId'
      @publishEvent 'showBitsHistory'
      Backbone.$("#bitRecordContent").show()

    if optionId == 'waitingListHId'
      @publishEvent 'showWaitingList'
      Backbone.$("#waitingListContent").show()

    if optionId == 'wishListHId'
      @publishEvent 'showWishList'
      Backbone.$("#wishListContent").show()
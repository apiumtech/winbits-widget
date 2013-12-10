template = require 'views/templates/account/accordion'
View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'
vendor = require 'lib/vendor'

module.exports = class AccordionView extends View
  autoRender: yes
  container: 'main'
  template: template

  render: ->
    super

  initialize: ->
    super
    console.log 'Inicializando acordeon'
    @subscribeEvent 'renderAccordionOption', @renderAccordionOption
    @delegate 'click', '.btnBackToSite', @backToSite
    @delegate 'expanded', '.accordeonWinbits', @renderAccordionOption

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

  renderAccordionOption: (e, $option)->
    optionId = $option.attr("id")
    $optionContent = $option.next()
    optionsMap =
      ordersHistoryHId:
        event: 'showOrdersHistory'
      bitsHistoryHId:
        event: 'showBitsHistory'
      waitingListHId:
        event: 'showWaitingList'
      wishListHId:
        event: 'showWishList'

    @publishEvent optionsMap[optionId].event
    $optionContent.show()

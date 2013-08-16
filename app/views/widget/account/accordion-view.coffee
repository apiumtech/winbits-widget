template = require 'views/templates/account/accordion'
View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'

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
    @delegate 'click', '.btnBackToSite', @backToSite

  attach: ->
    super
    console.log 'attach acordeon'
    util.accordeon
      obj: '.accordeonWinbits'
      trigger: 'h2'
      first: false # Si quieren que sea abra el primer elemento en la carga, poner TRUE
      claseActivo: 'activo'
      contenedor: '.accordeonContent'
      minusIcon: 'minusIcon'

    console.log 'END Inicializando acordeon'

  backToSite: (e) ->
    Backbone.$("#historicalAccordion").hide()

  cleanAccordion:  ->
    console.log('Limpiando acordion')
    Backbone.$(".accordeonContent").hide()

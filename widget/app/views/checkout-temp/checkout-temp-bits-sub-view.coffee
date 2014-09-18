'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class CheckOutTempTotalSubView extends View
  template: require './templates/checkout-temp-bits'


  initialize:()->
    super
    @listenTo @model,  'change:total', -> @render()

  attach: ->
    super
    $winbitsSlider = @$('#wbi-order-bits-slider').customSlider()
    @doChangeSliderBits($winbitsSlider)

  doChangeSliderBits: (obj)->
    $winbitsSlider = obj.closest('div .ui-slider')
    $winbitsSlider.on('slide', (e, ui={}) =>
      slideValue = obj.data('max-selection')
      if ui.value <= slideValue
        slideValue = ui.value
      @model.set 'bitsTotal', slideValue
#      console.log [@model._listenId]
    )

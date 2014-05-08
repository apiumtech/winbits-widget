View = require 'views/base/view'
$ = Winbits.$
utils = require 'lib/utils'

module.exports = class CartBitsView extends View
  container: '#wbi-cart-right-panel'
  template: require './templates/cart-bits'
  id: 'wbi-cart-bits'
  className: 'winSave'

  initialize: ->
    super
#    @delegate 'slider', '.ui-slider', @doChangeSliderBits

  attach: ->
    super
    $winbitsSlider = @$('#wbi-cart-bits-slider').customSlider()
    @doChangeSliderBits($winbitsSlider)

  doChangeSliderBits: (obj)->
#    debounceSlide = _.debounce( $.proxy(($slider, $amountEm, bits) ->
#      @delay = false
#      emValue = parseInt($amountEm.text())
#      if emValue is bits
#        @updateBalanceValues(@, $slider, bits)
#    , @),1500)
    $winbitsSlider = obj.closest('div .ui-slider')
    $winbitsSlider.on('slide', $.proxy((e, ui) ->
      slideValue = obj.data('max-selection')
      if ui.value <= slideValue then slideValue = ui.value
      @model.set 'bitsTotal', slideValue
      percentageSaved = utils.formatPercentage(@model.cartPercentageSaved())
      @$('#wbi-cart-percentage-saved').text(percentageSaved)
    ,@))
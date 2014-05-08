View = require 'views/base/view'
$ = Winbits.$
_ = Winbits._
utils = require 'lib/utils'

module.exports = class CartBitsView extends View
  container: '#wbi-cart-right-panel'
  template: require './templates/cart-bits'
  id: 'wbi-cart-bits'
  className: 'winSave'

  initialize: ->
    super

  attach: ->
    super
    $winbitsSlider = @$('#wbi-cart-bits-slider').customSlider()
    @doChangeSliderBits($winbitsSlider)

  doChangeSliderBits: (obj)->
    $winbitsSlider = obj.closest('div .ui-slider')


    debounceSlide = _.debounce( $.proxy((bits) ->
      @delay = no
      emValue = parseInt($winbitsSlider.find(".slider-amount em").text())
      if emValue is bits
        @updateBalanceValues($winbitsSlider, bits)
    , @),1500)


    $winbitsSlider.on('slide', $.proxy((e, ui) ->
      slideValue = obj.data('max-selection')
      if ui.value <= slideValue then slideValue = ui.value
      @model.set 'bitsTotal', slideValue
      percentageSaved = utils.formatPercentage(@model.cartPercentageSaved())
      @$('#wbi-cart-percentage-saved').text(percentageSaved)
    ,@))

#    if utils.isLoggedIn()
    $winbitsSlider.on('slidechange', $.proxy((e, ui) ->
      @delay = yes
      debounceSlide ui.value
    ,@))

  updateBalanceValues: ($slider, bits) ->
    $maxBits = $slider.slider('option', 'max')
    if $maxBits > 0
      @updateCartBits bits


  updateCartBits: (bits) ->
    if utils.isLoggedIn()
      data = [bitsTotal : bits]
      @model.updateCartBits(data, context:@)
      .done(@updateCartBitsSuccess)
      .fail(@updateCartBitsError)

  updateCartBitsSuccess: (data) ->
    bitsTotal= data.response.bitsTotal
    @model.set 'bitsTotal', bitsTotal
    @publishEvent 'change-bits-data', bitsTotal

  updateCartBitsError: (xhr, textStatus) ->
    error = utils.safeParse(xhr.responseText)
    messageText = "Error guardando el registro #{textStatus}"
    message = if error then error.meta.message else messageText
    options = value: "Cerrar", title:'Error'
    utils.showMessageModal(message, options)










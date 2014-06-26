View = require 'views/base/view'
$ = Winbits.$
_ = Winbits._
mediator = Winbits.Chaplin.mediator
utils = require 'lib/utils'

module.exports = class CartBitsView extends View
  container: '#wbi-cart-right-panel'
  template: require './templates/cart-bits'
  id: 'wbi-cart-bits'
  className: 'winSave'

  initialize: ->
    super
    @subscribeEvent 'bits-updated', @updateMaxSelection

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
    , @),1000)

    $winbitsSlider.on('slide', $.proxy((e, ui={}) ->
      slideValue = obj.data('max-selection')
      if ui.value <= slideValue
        slideValue = ui.value
      @model.set 'bitsTotal', slideValue
      percentageSaved = utils.formatPercentage(@model.cartPercentageSaved())
      @$('#wbi-cart-percentage-saved').text(percentageSaved)
    ,@))

    $winbitsSlider.on('slidechange', $.proxy((e, ui) ->
      $value = if ui?.value then ui.value else 0
      @delay = yes
      debounceSlide $value
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
    else
      utils.saveBitsInVirtualCart bits

  updateCartBitsSuccess: (data) ->
    bitsTotal= data.response.bitsTotal
    @model.set 'bitsTotal', bitsTotal
    mediator.data.set 'bits-to-cart', bitsTotal
    @publishEvent 'change-bits-data'

  updateCartBitsError: (xhr, textStatus) ->
    $maxSelection = @$('#wbi-cart-bits-slider').data('max-selection')
    $bitsTotal =$maxSelection - parseInt( $('#wbi-my-bits').text())
    @model.set 'bitsTotal', $bitsTotal
    @render()
    error = utils.safeParse(xhr.responseText)
    messageText = "Error guardando el registro #{textStatus}"
    message = if error then error.meta.message else messageText
    options = value: "Cerrar", title:'Error'
    utils.showMessageModal(message, options)


  updateMaxSelection:()->
    @$('#wbi-cart-bits-slider').data('max-selection', mediator.data.get('login-data').bitsBalance)

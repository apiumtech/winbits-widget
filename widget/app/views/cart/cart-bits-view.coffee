View = require 'views/base/view'
$ = Winbits.$
_ = Winbits._
mediator = Winbits.Chaplin.mediator
utils = require 'lib/utils'
cartUtils = require 'lib/cart-utils'

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
      emValue = parseInt($winbitsSlider.find(".slider-amount em").text().replace(/\,/g,''))
      if emValue is bits
        @updateBalanceValues($winbitsSlider, bits)
    , @),500)

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
      if @bits isnt bits
        @bits = bits
        @updateCartBits bits


  updateCartBits: (bits) ->
    cartUtils.showCartLoading()
    if utils.isLoggedIn()
      data = [bitsTotal : bits]
      @model.updateCartBits(data, context:@)
      .done(@updateCartBitsSuccess)
      .fail(@updateCartBitsError)
    else
      utils.saveBitsInVirtualCart bits
      @checkPaymentMethods()

  checkPaymentMethods: ->
    @model.requestPaymentMethods(@)
     .done(@setPaymentMethods)
     .fail((xhr)->console.log ["xhr", xhr.responseText])
     .always(cartUtils.hideCartLoading)

  setPaymentMethods:(data) ->
    @model.set('paymentMethods', data.response.paymentMethods)

  updateCartBitsSuccess: (data) ->
    cartUtils.hideCartLoading()
    bitsTotal= data.response.bitsTotal
    @model.set 'bitsTotal', bitsTotal
    mediator.data.set 'bits-to-cart', bitsTotal
    @model.set 'paymentMethods',data.response.paymentMethods
    @publishEvent 'change-bits-data'

  updateCartBitsError: (xhr, textStatus) ->
    cartUtils.hideCartLoading()
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

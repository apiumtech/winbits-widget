View = require 'views/base/view'
template = require 'views/templates/checkout/order-detail'
util = require 'lib/util'
config = require 'config'
vendor = require 'lib/vendor'

# Site view is a top-level view which is bound to body.
module.exports = class OrderDetailView extends View
  container: '#order-detail'
  autoRender: false
  template: template

  initialize: ->
    super
<<<<<<< Updated upstream
=======

>>>>>>> Stashed changes
  attach: ->
    super
    that = @
    if Winbits.checkoutConfig.bitsBalance > 0

      debounceSlide = _.debounce( ($slider, $amountEm, bits) ->
          emValue = parseInt($amountEm.text())
          if emValue is bits
            util.updateOrderDetailView(that.model, bits, $slider)
            that.updateOrderBits bits
      , 500)

      vendor.customSlider("#wbi-bits-slide-checkout").on('slidechange', (e, ui) ->
        $slider = Winbits.$(@)
        $amountEm = Winbits.$(this).find(".amount em")
        debounceSlide $slider, $amountEm, ui.value
      )

    if this.model.get("cashTotal") is 0
        @publishEvent "showBitsPayment"


  updateOrderBits: (bits) ->
    @model.updateOrderBits(bits)

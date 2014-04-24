'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class ShippingAddressesView extends View
  container: '#wb-shipping-addresses'
  template: require './templates/shipping-addresses'

  initialize: ->
    super
    @model.requestGetShippingAddresses(context: @)
     .done((data) ->
        @model.shippingAddresses = data.response
      )
     .fail(@getFailShippingAddresses)

  attach: ->
    super
    @$('.block-carrusel').changeBox(
          activo: 'carruselSCC-selected',
          items: '.carruselSCC-div'
       )
    .carouselSwiper(
          optionsSwiper:
            slideClass: 'block-slide',
            wrapperClass: 'block-wrapper',
            grabCursor: true,
            useCSS3Transforms: false,
            cssWidthAndHeight: false,
            slidesPerView: 4
         arrowLeft: '.iconFont-left',
         arrowRight: '.iconFont-right',
         slidesNum: 4,
         slideCSS: '.block-slide',
         initialSlide: '.carruselSCC-selected'
      )

  getSuccessShippingAddresses:(data) ->
    console.log ["Get shipping Addresses",data.response]

  getFailShippingAddresses:(xhr) ->
    console.log ["ERROR GETTING SHIPPING ADDRESSES", xhr.responseText]
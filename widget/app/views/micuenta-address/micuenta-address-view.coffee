'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class MiCuentaAddressView extends View
  container: '.wbc-my-account-container'
  id: 'wbi-micuenta-address'
  template: require './templates/micuenta-address'

  initialize: ->
    super

  attach: ->
    super
    @$('.block-carrusel')
      .changeBox(
          activo: 'carruselSCC-selected',
          items: '.carruselSCC-div' )
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
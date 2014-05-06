'use strict'

View = require 'views/base/view'
$ = Winbits.$

module.exports = class CardsView extends View
  container: '#wb-credit-cards'
  template: require './templates/cards'

  initialize: ->
    super

  attach: ->
    super
    @$('.block-carrusel').changeBox(
          activo: 'carruselSCC-selected',
          items: '.carruselSCC-div'
       )
    .carouselSwiper({
          optionsSwiper:{
            slideClass: 'block-slide',
            wrapperClass: 'block-wrapper',
            grabCursor: true,
            useCSS3Transforms: false,
            cssWidthAndHeight: false,
            slidesPerView: 4
            },
          arrowLeft: '.iconFont-left',
          arrowRight: '.iconFont-right',
          slidesNum: 4,
          slideCSS: '.block-slide',
          initialSlide: '.carruselSCC-selected'
    })

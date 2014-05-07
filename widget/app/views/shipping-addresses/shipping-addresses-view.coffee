'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
AddNewShippingAddress = require './add-new-shipping-address-view'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class ShippingAddressesView extends View
  container: '#wb-shipping-addresses'
  template: require './templates/shipping-addresses'

  initialize: ->
    super
    @listenTo @model,  'change', -> @render()
    @model.fetch()
    @delegate 'click', '#wbi-add-new-shipping-address' , @showAddNewShipping
    @delegate 'click', '#wbi-add-shipping-address-cancel', @cancelAddNewShipping
    @delegate 'click', '#wbi-shipping-address-done-btn', @cancelAddNewShipping
    @delegate 'click', '.wbc-delete-link', @doDeleteShipping


  render: ->
    super
    newShippingAddressContainer = @$el.find('#wbi-shipping-new-address-container')
    @subview 'add-new-shipping-addresses', new AddNewShippingAddress container: newShippingAddressContainer, model: @model

  attach: ->
    super
    #script to implement carrusel
    @$('.block-carrusel').carouselSwiper({
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

  showAddNewShipping:(e) ->
    e.preventDefault()
    @$('#wbi-shipping-addresses-view').slideUp()
    @$('#wbi-shipping-new-address-container').slideDown()


  cancelAddNewShipping: (e) ->
    e.preventDefault()
    @$('#wbi-shipping-addresses-view').slideDown()
    @$('#wbi-shipping-new-address-container').slideUp()
    $form = @$('#wbi-shipping-new-address-form')
    utils.justResetForm($form)
    if not @$('.thanks-div').is(':hidden')
      @$('#wbi-shipping-thanks-div').slideUp()
      @model.fetch()

  doDeleteShipping: (e) ->
    e.stopPropagation()
    $itemId = $(e.currentTarget).closest('.block-slide').data("id")
    message = "¿Estás seguro de eliminar esta dirección de envío? <br><br> En caso de eliminarla las compras relacionadas a esta direccion no se verán afectadas"
    options =
      value: "Aceptar"
      title:'Confirmacion de borrado'
      icon:'iconFont-question'
      context: @
      acceptAction: () -> @doRequestDeleteShippingAddress($itemId)
    utils.showConfirmationModal(message, options)

  doRequestDeleteShippingAddress:($itemId) ->
   @model.requestDeleteShippingAddress($itemId, context:@)
     .done(@doSuccessDeleteShippingAddress)
     .fail(@doErrorDeleteShippingAddress)

  doSuccessDeleteShippingAddress: ->
    message = "La dirección se ha eliminado correctamente"
    options = value: "Continuar", title:'Direccion de envío eliminada', icon:'iconFont-ok', onClosed: utils.redirectTo controller: 'home', action: 'index'
    utils.showMessageModal(message, options)
    @model.fetch()

  doErrorDeleteShippingAddress: (xhr) ->
    console.log ["SHIPPING ADDRESS DOES NOT DELETED", xhr.responseText]
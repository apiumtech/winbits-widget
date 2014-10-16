'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
AddNewShippingAddress = require './add-new-shipping-address-view'
EditShippingAddressView = require './edit-shipping-address-view'
EditShippingAddressModel = require 'models/shipping-addresses/edit-shipping-address'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env
DEFAULT_SHIPPING_CLASS = 'carruselSCC-selected'

module.exports = class ShippingAddressesView extends View
  container: '#wb-shipping-addresses'
  template: require './templates/shipping-addresses'

  initialize: ->
    super
    @listenTo @model,  'change', -> @render()
    @model.fetch()
    @clickOnShippingHandler = @delegate 'click', '.wbc-shipping', -> @onShippingClick.apply(@, arguments)
    @delegate 'click', '#wbi-add-new-shipping-address' , @showAddNewShipping
    @delegate 'click', '#wbi-add-shipping-address-cancel', @cancelAddNewShipping
    @delegate 'click', '#wbi-edit-shipping-address-cancel', @cancelEditShipping
    @delegate 'click', '#wbi-shipping-address-done-btn', @cancelAddNewShipping
    @delegate 'click', '#wbi-edit-shipping-address-done-btn', @cancelEditShipping
    @delegate 'click', '.wbc-delete-shipping-link', @doDeleteShipping
    @delegate 'click', '.wbc-edit-shipping-link', @doEditShippingAddress


  render: ->
    super
    newShippingAddressContainer = @$el.find('#wbi-shipping-new-address-container')
    @subview 'add-new-shipping-addresses', new AddNewShippingAddress container: newShippingAddressContainer, model: @model
    @subview 'edit-address-view', new EditShippingAddressView container: '#wbi-edit-shipping-address-container'

  attach: ->
    super
    #script to implement carrusel

    @$('.block-carrusel').changeBox({
      activo: '',
      items: '.carruselSCC-div'
       }).carouselSwiper({
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

  onShippingClick: (e) ->
    e.stopPropagation()
    $shipping = $(e.currentTarget)
    if not $shipping.children(".#{DEFAULT_SHIPPING_CLASS}").length > 0
      utils.showAjaxLoading()
      id = $shipping.closest('.block-slide').data('id')
      data = @model.getShippingAddress(id)
      dataChange = @checkZipCodeInfoAndChange(data)
      @shippingCandidate = $shipping
      @turnShippingClickEvent('off')
      @model.requestSetDefaultShipping(id,dataChange, @)
      .done(@setDefaultShippingSucceds)
      .fail(@setDefaultShippingError)
      .always(@closeLoadingAndTurnOnClickEvent)
    @calculateArrows()

  closeLoadingAndTurnOnClickEvent: ->
    @turnShippingClickEvent('on')
    utils.hideAjaxLoading()

  calculateArrows:->
    @$('.block-carrusel').removeArrows({
      arrowLeft: '.iconFont-left',
      arrowRight: '.iconFont-right',
      slidesNum: 4,
      slideCSS: '.block-slide'
    });

  checkZipCodeInfoAndChange: (data)->
    dataChange={}
    if not data.zipCodeInfo
      return $.extend(dataChange, data, {main: true, zipCodeInfo: "-1"})
    else
      return $.extend(dataChange, data, main: true)

  setDefaultShippingError: ->
    message = "Por el momento no es posible marcar como dirección principal, inténtalo más tarde"
    options = value: "Continuar", title:'Error', icon:'iconFont-info', onClosed: utils.redirectTo controller: 'home', action: 'index'
    utils.showMessageModal(message, options)

  setDefaultShippingSucceds: ->
    @getDefaultShipping().removeClass(DEFAULT_SHIPPING_CLASS)
    @shippingCandidate.children().addClass(DEFAULT_SHIPPING_CLASS)

  getDefaultShipping: ->
    @$(".#{DEFAULT_SHIPPING_CLASS}")

  turnShippingClickEvent: (state) ->
    @$el[state]('click', '.wbc-shipping', @clickOnShippingHandler)

  showAddNewShipping:(e)->
    e.preventDefault()
    @$('#wbi-shipping-addresses-view').slideUp()
    @$('#wbi-shipping-new-address-container').slideDown()

  cancelAddNewShipping: (e)->
    e.preventDefault()
    @$('#wbi-shipping-addresses-view').slideDown()
    @$('#wbi-shipping-new-address-container').slideUp()
    $form = @$('#wbi-shipping-new-address-form')
    utils.justResetForm($form)
    $thanksDiv = @$('#wbi-shipping-thanks-div')
    @checkThanksDivAndRenderView($thanksDiv)

  cancelEditShipping: (e)->
    e.preventDefault()
    @$('#wbi-shipping-addresses-view').slideDown()
    @$('#wbi-edit-shipping-address-container').slideUp()
    $form = @$('#wbi-edit-shipping-address-form')
    utils.justResetForm($form)
    $thanksDiv = @$('#wbi-edit-shipping-thanks-div')
    @checkThanksDivAndRenderView($thanksDiv)


  doDeleteShipping: (e)->
    e.stopPropagation()
    @itemId = $(e.currentTarget).closest('.block-slide').data("id")
    message = "¿Estás seguro de eliminar esta dirección de envío? <br><br> En caso de eliminarla las compras relacionadas a esta dirección no se verán afectadas"
    options =
      value: "Aceptar"
      title:'Confirmacion de borrado'
      icon:'iconFont-question'
      context: @
      acceptAction:@doRequestDeleteShippingAddress
    utils.showConfirmationModal(message, options)

  doRequestDeleteShippingAddress:() ->
    utils.closeMessageModal()
    utils.showAjaxLoading()
    @model.requestDeleteShippingAddress(@itemId, context:@)
      .done(@doSuccessDeleteShippingAddress)
      .fail(@doErrorDeleteShippingAddress)

  doSuccessDeleteShippingAddress: ->
    utils.hideAjaxLoading()
    @model.fetch()
    message = "La dirección se ha eliminado correctamente"
    options = value: "Continuar", title:'Direccion de envío eliminada', icon:'iconFont-ok'
    utils.showMessageModal(message, options)

  doErrorDeleteShippingAddress: () ->
    message = "Hubo un error al intentar eliminar la direccion, intentalo mas tarde"
    options = value: "Continuar", title:'Error al eliminar', icon:'iconFont-close'
    utils.showMessageModal(message, options)

  doEditShippingAddress: (e) ->
    e.preventDefault()
    e.stopPropagation()
    itemId = $(e.currentTarget).closest('.block-slide').data("id")
    address = @model.getShippingAddress(itemId)
    editModel = new EditShippingAddressModel(address)
    @subview 'edit-address-view', new EditShippingAddressView container: '#wbi-edit-shipping-address-container', model: editModel
    @$('#wbi-shipping-addresses-view').slideUp()
    @$('#wbi-edit-shipping-address-container').slideDown()

  checkThanksDivAndRenderView:($thanksDiv)->
    if not $thanksDiv.is(':hidden')
      $thanksDiv.slideUp()
      @model.fetch()

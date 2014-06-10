View = require 'views/base/view'
template = require 'views/templates/checkout/addresses'
utils = require 'lib/util'
vendor = require 'lib/vendor'
config = require 'config'
mediator = require 'chaplin/mediator'
AddNewShippingAddress = require './add-new-shipping-address-view'
EditShippingAddressView = require './edit-new-shipping-address-view'
AddressCK = require 'models/checkout/addressCK'
Address = require 'models/checkout/address'

# Site view is a top-level view which is bound to body.
module.exports = class AddressManagerView extends View
  container: '.shippingAddressesContainer'
  template: template

  initialize: ->
    super
    @subscribeEvent 'addresses-changed', @updateShippingAddressView
    @listenTo @model,  'change', -> @render()
    @delegate 'click', '#aNewAddress' , @showAddNewShipping
    @delegate 'click', '.wbc-delete-shipping-link', @doDeleteShipping
    @delegate 'click', '.wbc-edit-shipping-link', @doEditShipping
    @shippingAddressNew = new AddNewShippingAddress model: new Address, autoRender: no
    @editShippingAddressView = new EditShippingAddressView model: new Address, autoRender: no
    @delegate "click" , ".shippingItem", @selectShipping
    @delegate "click" , "#btnContinuar", @addressContinuar
  
  render: ->
    super
  
  dispose: ->
    super
    @shippingAddressNew.dispose()
    @editShippingAddressView.dispose()

  attach: ->
   super
   
  showAddNewShipping:(e)->
    e.preventDefault()
    @shippingAddressNew.render()
    @$('#wbi-shipping-addresses-view').hide()
    @$('#wbi-shipping-new-address-container').show()
    @$('.errorDiv p').text('').parent().css('display':'none')
  
  doDeleteShipping: (e)->
    $currentTarget = @$(e.currentTarget)
    that = @
    itemId =  Winbits.$(e.currentTarget).closest('.shippingMenu').data("id")
    answer = confirm '¿En verdad quieres eliminar esta dirección de envío?'
    if answer
      utils.showAjaxIndicator('Eliminando dirección de envío...')
      @model.requestDeleteShippingAddress(itemId, context:@)
        .done(@doSuccessDeleteShippingAddress)
        .fail(@doErrorDeleteShippingAddress)
        .always(@doCompleteDeleteShippingAddress)

  doErrorDeleteShippingAddress:(xhr, textStatus) ->
    headers:{ 'Accept-Language': 'es', 'WB-Api-Token': Winbits.env.get('api-url')}
    error = utils.safeParse(xhr.responseText)
    message = if error then error.meta.message else textStatus
    @$('.errorDiv p').text(message).parent().css('display':'block')

  doSuccessDeleteShippingAddress: ->
    @model.actualiza()
  
  doCompleteDeleteShippingAddress: ->
    utils.hideAjaxIndicator()
   
  doEditShipping:(e) ->
    e.preventDefault()
    itemId = Winbits.$(e.currentTarget).closest('.shippingMenu').data("id")
    address = @model.getShippingAddress itemId
    @editShippingAddressView.model.set(address)
    @editShippingAddressView.render()
    @$('#wbi-shipping-addresses-view').hide()
    @$('#wbi-edit-shipping-address-container').show()
  
  updateShippingAddressView: ->
    @model.actualiza()
    Winbits.$('#wbi-edit-shipping-address-container').html('')  
    Winbits.$('#wbi-edit-shipping-address-container').hide()
    Winbits.$('#wbi-shipping-addresses-view').show()

   addressContinuar: (e)->
     $addresSelected = @$(".shippingSelected")
     if $addresSelected.attr("id") != undefined
       id = $addresSelected.attr("id").split("-")[1]
       if id
         mediator.post_checkout.shippingAddress = id
         @publishEvent "showStep", ".checkoutPaymentContainer"
         @$("#choosen-address-" + mediator.post_checkout.shippingAddress).show()
       else
         utils.showError('Selecciona una dirección de envío para continuar')
     else
       utils.showError('Agrega o selecciona una dirección de envío para continuar') 

   selectShipping: (e)->
     $currentTarget = @$(e.currentTarget)
     id =  $currentTarget.attr("id").split("-")[1]
     @$(".shippingItem").removeClass("shippingSelected")
     $currentTarget.addClass("shippingSelected")
     mediator.post_checkout.shippingAddress = id


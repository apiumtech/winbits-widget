View = require 'views/base/view'
template = require 'views/templates/checkout/addresses'
utils = require 'lib/util'
vendor = require 'lib/vendor'
config = require 'config'
mediator = require 'chaplin/mediator'
AddNewShippingAddress = require './add-new-shipping-address-view'
EditShippingAddressView = require './edit-new-shipping-address-view'
AddressCK = require 'models/checkout/addressCK'

# Site view is a top-level view which is bound to body.
module.exports = class AddressManagerView extends View
  container: '.shippingAddressesContainer'
  template: template

  initialize: ->
    super
    @listenTo @model,  'change', -> @render()
    @delegate 'click', '#aNewAddress' , @showAddNewShipping
    @delegate 'click', '.wbc-delete-shipping-link', @doDeleteShipping
    @delegate 'click', '.wbc-edit-shipping-link', @doEditShipping
    @subscribeEvent 'updateShippingAddressView', @updateShippingAddressView
    @shippingAddressNew = new AddNewShippingAddress model: @model, autoRender: no
    @editShippingAddressView = new EditShippingAddressView
  
  render: ->
    super
    @shippingAddressNew.render()
  
  dispose: ->
    super
    @shippingAddressNew.dispose()
    @editShippingAddressView.dispose()

  attach: ->
   super
   
  showAddNewShipping:(e)->
    e.preventDefault()
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
        .complete(@doCompleteDeleteShippingAddress)

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
    editModel = new AddressCK address
    @editShippingAddressView = new EditShippingAddressView model: editModel, autoRender: no
    @editShippingAddressView.render()
    @$('#wbi-shipping-addresses-view').hide()
    @$('#wbi-edit-shipping-address-container').show()
  
  updateShippingAddressView: ->
    console.log 'model updating'
    @model.actualiza()
    Winbits.$('#wbi-edit-shipping-address-container').html('')  
    Winbits.$('#wbi-edit-shipping-address-container').hide()
    Winbits.$('#wbi-shipping-addresses-view').show()

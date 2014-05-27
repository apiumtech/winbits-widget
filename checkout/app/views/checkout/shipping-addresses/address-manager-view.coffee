View = require 'views/base/view'
template = require 'views/templates/checkout/addresses'
util = require 'lib/util'
vendor = require 'lib/vendor'
config = require 'config'
mediator = require 'chaplin/mediator'
#zipCode = require 'lib/zipCode'
AddNewShippingAddress = require './add-new-shipping-address-view'
AddressCK = require 'models/checkout/addressCK'

# Site view is a top-level view which is bound to body.
module.exports = class AddressManagerView extends View
  container: '.shippingAddressesContainer'
  template: template

  initialize: ->
    super
    @listenTo @model,  'change', -> @render()
    #@model.actualiza()
    @delegate 'click', '#aNewAddress' , @showAddNewShipping
    @shippingAddressNew = new AddNewShippingAddress model: @model, autoRender: yes
  
  render: ->
    super
    @shippingAddressNew.render()
    #@subview 'new-shipping-addresses', shippingAddressNew
  
  dispose: ->
    super
    @shippingAddressNew.dispose()

  attach: ->
   super
   
  # that = @
    #$editForms = @$("form.shippingEditAddress")

    #$editForms.each ->
    # $form = that.$(this)
    # $select = $form.find('.select')
    # $zipCode = $form.find('.zipCode')
    # $zipCodeExtra = $form.find('.zipCodeInfoExtra')
      #zipCode(Winbits.$).find $zipCode.val(), $select, $zipCodeExtra.val()
      #unless $zipCode.val().length < 5
      #  vendor.customSelect($select)

    #$form = @$el.find('form#shippingNewAddress')
    #vendor.customSelect($form.find(".select"))

    #$shippingAddresses = @$el.find('li.wb-shipping-address')
    #$shippingAddresses.first().addClass('shippingSelected') if $shippingAddresses.filter('.shippingSelected').length is 0
  
  showAddNewShipping:(e)->
    e.preventDefault()
    @$('#wbi-shipping-addresses-view').hide()
    @$('#wbi-shipping-new-address-container').show()


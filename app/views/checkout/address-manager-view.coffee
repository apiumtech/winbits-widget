View = require 'views/base/view'
template = require 'views/templates/checkout/addresses'
util = require 'lib/util'
config = require 'config'

# Site view is a top-level view which is bound to body.
module.exports = class CheckoutSiteView extends View
  container: '.shippingAddressesContainer'
  autoRender: yes
  #regions:
  #'#header-container': 'header'
  #'#page-container': 'main'
  template: template

  initialize: ->
    super
    @delegate "click" , "#aNewAddress", @newAddress
    @delegate "click" , "#btnCancel", @cancelEdit
    @delegate "click" , "#btnSubmit", @addressSubmit

  newAddress: (e)->
    e.preventDefault()
    @$(".shippingAddresses").hide()
    @$(".shippingNewAddress").show()

  cancelEdit: (e)->
    e.preventDefault()
    @$(".shippingAddresses").show()
    @$(".shippingNewAddress").hide()

  addressSubmit: (e)->
    e.preventDefault()
    console.log "AddressSubmit"
    $form = @$el.find("#shippingNewAddress")
    console.log $form.valid()
    if $form.valid()
      data: JSON.stringify(formData)
      formData = util.serializeForm($form)
      formData.country  = {"id": formData.country}
      formData.zipCodeInfo  = {"id": '4000'}
      if formData.principal
        formData.principal  = true
      else
        formData.principal = false
      console.log formData
      @model.set formData
      @model.sync 'create', @model,
        error: ->
          console.log "error",
        headers:{ 'Accept-Language': 'es', 'WB-Api-Token': util.getCookie(config.apiTokenName) }
        success: ->
          console.log "success"
          #that.$el.find(".myPerfil").slideDown()

  attach: ->
    super
    console.log "CheckoutSiteView#attach"

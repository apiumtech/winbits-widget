View = require 'views/base/view'
template = require 'views/templates/checkout/addresses'
util = require 'lib/util'
config = require 'config'
mediator = require 'chaplin/mediator'
zipCode = require 'lib/zipCode'

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
    @delegate "click" , ".btnUpdate", @addressUpdate
    @delegate "click" , ".edit-address", @editAddress
    @delegate "click" , ".delete-address", @deleteAddress
    @delegate "click" , "#btnContinuar", @addressContinuar
    @delegate "click" , ".shippingItem", @selectShipping
    @delegate 'keyup', '.zipCode', @findZipcode

  deleteAddress: (e)->
    console.log "deleting address"
    $currentTarget = @$(e.currentTarget)
    that = @
    id =  $currentTarget.attr("id").split("-")[1]
    @model.sync 'delete', @model,
      url: config.apiUrl + "/affiliation/shipping-addresses/" + id,
      error: ->
        console.log "error",
      headers:{ 'Accept-Language': 'es', 'WB-Api-Token': util.getCookie(config.apiTokenName) }
      success: ->
        console.log "success"
        that.model.actualiza()

  selectShipping: (e)->
    $currentTarget = @$(e.currentTarget)
    console.log $currentTarget.attr("id")
    id =  $currentTarget.attr("id").split("-")[1]
    @$(".shippingItem").removeClass("shippingSelected")
    $currentTarget.addClass("shippingSelected")
    mediator.post_checkout.shippingAddress = id


  addressContinuar: (e)->
    console.log "continuar"
    $addresSelected = @$(".shippingSelected")
    id = $addresSelected.attr("id").split("-")[1]
    if id
      mediator.post_checkout.shippingAddress = id
    if mediator.post_checkout.shippingAddress
      @publishEvent "showStep", ".checkoutPaymentContainer"
      @$("#choosen-address-" + mediator.post_checkout.shippingAddress).show()


  editAddress: (e)->
    e.principal
    $currentTarget = @$(e.currentTarget)
    id =  $currentTarget.attr("id").split("-")[1]
    $editAddress = @$("#shippingEditAddress-" + id)
    @$(".shippingAddresses").hide()
    $editAddress.show()
  newAddress: (e)->
    e.preventDefault()
    @$(".shippingAddresses").hide()
    @$("#shippingNewAddress").show()

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
      formData.zipCodeInfo  = {"id": formData.zipCodeInfoId}
      if formData.principal
        formData.principal  = true
      else
        formData.principal = false
      formData.contactName = formData.name + " " + formData.lastname
      formData.contactPhone = formData.phone
      console.log formData
      @model.set formData


      that = @
      @model.sync 'create', @model,
        error: ->
          console.log "error",
        headers:{ 'Accept-Language': 'es', 'WB-Api-Token': util.getCookie(config.apiTokenName) }
        success: ->
          console.log "success"
          that.model.actualiza()
          #that.$el.find(".myPerfil").slideDown()
          #
  addressUpdate: (e)->
    e.preventDefault()
    console.log "AddressUpdate"
    $currentTarget = @$(e.currentTarget)
    id =  $currentTarget.attr("id").split("-")[1]
    $form = @$el.find("#shippingEditAddress-" + id)
    if $form.valid()
      formData = util.serializeForm($form)
      formData.country  = {"id": formData.country}
      formData.zipCodeInfo  = {"id": formData.zipCodeInfoId}
      if formData.principal
        formData.principal  = true
      else
        formData.principal = false
      formData.contactName = formData.name + " " + formData.lastname
      console.log formData
      @model.set formData
      that = @
      @model.sync 'update', @model,
        url: config.apiUrl + "/affiliation/shipping-addresses/" + formData.id,
        error: ->
          console.log "error",
        headers:{ 'Accept-Language': 'es', 'WB-Api-Token': util.getCookie(config.apiTokenName) }
        success: ->
          console.log "success"
          that.model.actualiza()

  attach: ->
    super
    console.log "CheckoutSiteView#attach"
    util.customCheckbox(@$(".checkbox"))
    that = this
    @$(".shippingEditAddress").each ->
      $select = that.$(this).find('.select')
      $zipCode = that.$(this).find('.zipCode')
      $zipCodeExtra = that.$(this).find('.zipCodeInfoExtra')
      zipCode(Backbone.$).find $zipCode.val(), $select, $zipCodeExtra.val()
      unless $zipCode.val().length < 5
        util.customSelect($select)

    util.customSelect(@$(".shippingNewAddress").find(".select"))
  findZipcode: (event)->
    event.preventDefault()
    console.log "find zipCode"
    $currentTarget = @$(event.currentTarget)
    $slt = $currentTarget.parent().find(".select")
    console.log $currentTarget
    console.log $slt
    zipCode(Backbone.$).find $currentTarget.val(), $slt

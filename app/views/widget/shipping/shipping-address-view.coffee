template = require 'views/templates/shipping/address'
View = require 'views/base/view'
util = require 'lib/util'
vendor = require 'lib/vendor'
config = require 'config'
mediator = require 'chaplin/mediator'
zipCode = require 'lib/zipCode'

module.exports = class ShippingAddressView extends View
  autoRender: yes
  container: '#shippingAddressContent'
  template: template

  render: ->
    super

  initialize: ->
    super
    @subscribeEvent 'shippingReady', @handlerModelReady

    @delegate "click" , "#aNewAddress", @newAddress
    @delegate "click" , "#btnCancel", @cancelEdit
    @delegate "click" , "#btnSubmit", @addressSubmit
    @delegate "click" , ".btnUpdate", @addressUpdate
    @delegate "click" , ".edit-address", @editAddress
    @delegate "click" , ".delete-address", @deleteAddress
    @delegate 'keyup', '.zipCode', @findZipcode

  handlerModelReady: ->
    @render()

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
        that.publishEvent 'showShippingAddresses'

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
    @$(".shippingEditAddress").hide()

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
      formData.main = if formData.main then true else false
      console.log formData
      @model.set formData

      that = @
      @model.sync 'create', @model,
        error: ->
          console.log "error",
        headers:
              "Accept-Language": "es"
              "WB-Api-Token":  util.getCookie(config.apiTokenName)
        success: ->
              console.log "success"
              that.publishEvent 'showShippingAddresses'
              @$(".shippingAddresses").show()
              @$("#shippingNewAddress").hide()
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
          that.publishEvent 'showShippingAddresses'
          @$(".shippingAddresses").show()
          @$($currentTarget).hide()

  attach: ->
    super
    console.log "CheckoutSiteView#attach"
    vendor.customCheckbox(@$(".checkbox"))
    that = this
    @$(".shippingEditAddress").each ->
      $select = that.$(this).find('.select')
      $zipCode = that.$(this).find('.zipCode')
      $zipCodeExtra = that.$(this).find('.zipCodeInfoExtra')
      zipCode(Backbone.$).find $zipCode.val(), $select, $zipCodeExtra.val()
      unless $zipCode.val().length < 5
        vendor.customSelect($select)

    $form = @$el.find('form#shippingNewAddress')
    vendor.customSelect($form.find(".select"))
    $form.validate
      groups:
        addressNumber: 'externalNumber internalNumber'
      errorPlacement: ($error, $element) ->
        if $element.attr("name") is "externalNumber" or $element.attr("name") is "internalNumber"
          $error.appendTo $element.parent()
        else
          $error.insertAfter $element
      rules:
        firstName:
          required: true
          minlength: 2
        lastName:
          required: true
          minlength: 2
        phone:
          required: true
          minlength: 7
          digits: true
        street:
          required: true
          minlength: 2
        externalNumber:
          required: true
        internalNumber:
          minlength: 1
        betweenStreets:
          required: true
          minlength: 4
        indications:
          required: true
          minlength: 2
        zipCode:
          required: true
          minlength: 5
          digits: true
        location:
          minlength: 2

  findZipcode: (event)->
    event.preventDefault()
    console.log "find zipCode"
    $currentTarget = @$(event.currentTarget)
    $slt = $currentTarget.parent().find(".select")
    zipCode(Backbone.$).find $currentTarget.val(), $slt
View = require 'views/base/view'
template = require 'views/templates/checkout/addresses'
util = require 'lib/util'
vendor = require 'lib/vendor'
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
    @delegate 'change', 'select.zipCodeInfo', @changeZipCodeInfo

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
    @$(".shippingEditAddress").hide()

  addressSubmit: (e)->
    e.preventDefault()
    console.log "AddressSubmit"
    $form = @$el.find("#shippingNewAddress")
    console.log $form.valid()
    if $form.valid()
      data: JSON.stringify(formData)
      formData = util.serializeForm($form)
      formData = util.serializeForm($form)
      formData.country  = {"id": formData.country}
      if formData.zipCodeInfo and formData.zipCodeInfo > 0
        formData.zipCodeInfo  = {"id": formData.zipCodeInfo}
      formData.main = formData.main is true or formData.main is 'on'
      console.log formData
      @model.set formData

      that = @
      @model.sync 'create', @model,
        error: ->
          console.log "error",
        headers: { 'Accept-Language': 'es', 'WB-Api-Token': util.getCookie(config.apiTokenName) }
        success: ->
          console.log "success"
          that.model.actualiza()

  addressUpdate: (e)->
    e.preventDefault()
    console.log "AddressUpdate"
    $currentTarget = @$(e.currentTarget)
    id =  $currentTarget.attr("id").split("-")[1]
    $form = @$el.find("#shippingEditAddress-" + id)
    if $form.valid()
      formData = util.serializeForm($form)
      formData.country  = {"id": formData.country}
      if formData.zipCodeInfo and formData.zipCodeInfo > 0
        formData.zipCodeInfo  = {"id": formData.zipCodeInfo}
      formData.main = formData.main is true or formData.main is 'on'
      console.log formData
      @model.set formData
      that = @
      @model.sync 'update', @model,
        url: config.apiUrl + "/affiliation/shipping-addresses/" + formData.id + '.json',
        error: ->
          console.log "error",
        headers:{ 'Accept-Language': 'es', 'WB-Api-Token': util.getCookie(config.apiTokenName) }
        success: ->
          console.log "success"
          that.model.actualiza()

  attach: ->
    super
    console.log "AddressManagerView#attach"
    vendor.customCheckbox(@$(".checkbox"))
    that = this
    @$("form.shippingEditAddress").each ->
      $form = that.$(this)
      $select = $form.find('.select')
      $zipCode = $form.find('.zipCode')
      $zipCodeExtra = $form.find('.zipCodeInfoExtra')
      zipCode(Backbone.$).find $zipCode.val(), $select, $zipCodeExtra.val()
      unless $zipCode.val().length < 5
        vendor.customSelect($select)

    $form = @$el.find('form.shippingNewAddress')
    vendor.customSelect($form.find(".select"))

    @$el.find('form#shippingNewAddress').validate
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
        zipCodeInfo:
          required: (e) ->
            $form = Backbone.$(e).closest 'form'
            $form.find('[name=location]').is(':hidden')
        location:
          required: '[name=location]:visible'
          minlength: 2
        county:
          required: '[name=location]:visible'
          minlength: 2
        state:
          required: '[name=location]:visible'
          minlength: 2

  findZipcode: (event)->
    event.preventDefault()
    console.log "find zipCode"
    $currentTarget = @$(event.currentTarget)
    $slt = $currentTarget.parent().find(".select")
    zipCode(Backbone.$).find $currentTarget.val(), $slt

  changeZipCodeInfo: (e) ->
    $ = Backbone.$
    $select = $(e.currentTarget)
    zipCodeInfoId = $select.val()
    $form = $select.closest('form')
    $fields = $form.find('[name=location], [name=county], [name=state]')
    if !zipCodeInfoId
      $fields.show().val('').attr('readonly', '').filter('[name=location]').hide()
    else if zipCodeInfoId is '-1'
      $fields.show().removeAttr('readonly')
    else
      $fields.show().attr('readonly', '').filter('[name=location]').hide()
    $option = $select.children('[value=' + zipCodeInfoId + ']')
    zipCodeInfo = $option.data 'zip-code-info'
    if zipCodeInfo
      $form.find('input.zipCode').val zipCodeInfo.zipCode
      $fields.filter('[name=county]').val zipCodeInfo.county
      $fields.filter('[name=state]').val zipCodeInfo.state

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
    @delegate 'textchange', '.zipCode', @findZipcode
    @delegate 'change', 'select.zipCodeInfo', @changeZipCodeInfo

  handlerModelReady: ->
    @render()

  deleteAddress: (e)->
    console.log "deleting address"
    $currentTarget = @$(e.currentTarget)
    that = @
    id =  $currentTarget.attr("id").split("-")[1]
    answer = confirm '¿En verdad quieres eliminar esta dirección de envío?'
    if answer
      util.showAjaxIndicator('Eliminando dirección de envío...')
      @model.sync 'delete', @model,
        url: config.apiUrl + "/affiliation/shipping-addresses/" + id,
        error: ->
          console.log "error",
        headers:{ 'Accept-Language': 'es', 'WB-Api-Token': util.getCookie(config.apiTokenName) }
        success: ->
          console.log "success"
          that.publishEvent 'showShippingAddresses'
        complete: ->
          util.hideAjaxIndicator()

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
      if formData.zipCodeInfo and formData.zipCodeInfo > 0
        formData.zipCodeInfo  = {"id": formData.zipCodeInfo}
      formData.main = formData.hasOwnProperty('main')
      console.log formData
      @model.set formData
      submitButton = $form.find("#btnSubmit").prop('disabled', true)
      that = @
      @model.sync 'create', @model,
        context: {$submitButton: submitButton}
        error: ->
          console.log "error",
        headers:
              "Accept-Language": "es"
              "WB-Api-Token":  util.getCookie(config.apiTokenName)
        success: ->
              console.log "success"
              that.publishEvent 'showShippingAddresses'
        complete: ->
              this.$submitButton.prop('disabled', false)

  addressUpdate: (e)->
    e.preventDefault()
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
      submitUpdate = $form.find('.btnUpdate').prop('disabled', true)
      @model.sync 'update', @model,
        context: {$submitUpdate: submitUpdate}
        url: config.apiUrl + "/affiliation/shipping-addresses/" + formData.id + ".json",
        error: ->
          console.log "error",
        headers:{ 'Accept-Language': 'es', 'WB-Api-Token': util.getCookie(config.apiTokenName) }
        success: ->
          console.log "success"
          that.publishEvent 'showShippingAddresses'
        complete: ->
          this.$submitUpdate.prop('disabled', false)

  attach: ->
    super
    that = @
    $editForms = @$("form.shippingEditAddress")
    $editForms.each ->
      $form = that.$(this)
      $select = $form.find('.select')
      $zipCode = $form.find('.zipCode')
      $zipCodeExtra = $form.find('.zipCodeInfoExtra')
      zipCode(Backbone.$).find $zipCode.val(), $select, $zipCodeExtra.val()
      unless $zipCode.val().length < 5
        vendor.customSelect($select)

    $form = @$el.find('form#shippingNewAddress')
    vendor.customSelect($form.find(".select"))

    $editForms.add($form).validate
      groups:
        addressNumber: 'externalNumber internalNumber'
      errorPlacement: ($error, $element) ->
        if $element.attr("name") in ["externalNumber", "internalNumber", 'zipCodeInfo']
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
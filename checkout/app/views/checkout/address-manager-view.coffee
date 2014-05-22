View = require 'views/base/view'
template = require 'views/templates/checkout/addresses'
util = require 'lib/util'
vendor = require 'lib/vendor'
config = require 'config'
mediator = require 'chaplin/mediator'

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
  
  deleteAddress: (e)->
    $currentTarget = @$(e.currentTarget)
    that = @
    id =  $currentTarget.attr("id").split("-")[1]
    answer = confirm '¿En verdad quieres eliminar esta dirección de envío?'
    if answer
      util.showAjaxIndicator('Eliminando dirección de envío...')
      @model.sync 'delete', @model,
        url: config.apiUrl + "/users/shipping-addresses/" + id + '.json',
        error: ->
        headers:{ 'Accept-Language': 'es', 'WB-Api-Token': util.retrieveKey(config.apiTokenName) }
        success: ->
          that.model.actualiza()
        complete: ->
          util.hideAjaxIndicator()

  selectShipping: (e)->
    $currentTarget = @$(e.currentTarget)
    id =  $currentTarget.attr("id").split("-")[1]
    @$(".shippingItem").removeClass("shippingSelected")
    $currentTarget.addClass("shippingSelected")
    mediator.post_checkout.shippingAddress = id


  addressContinuar: (e)->
    $addresSelected = @$(".shippingSelected")
    if $addresSelected.attr("id") != undefined
      id = $addresSelected.attr("id").split("-")[1]
      if id
        mediator.post_checkout.shippingAddress = id
        @publishEvent "showStep", ".checkoutPaymentContainer"
        @$("#choosen-address-" + mediator.post_checkout.shippingAddress).show()
      else
        util.showError('Selecciona una dirección de envío para continuar')
    else
      util.showError('Agrega una dirección de envío para continuar')


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
    $form = @$el.find("#shippingNewAddress")
    if $form.valid()
      data: JSON.stringify(formData)
      formData = util.serializeForm($form)
      formData.country  = {"id": formData.country}
      if formData.zipCodeInfo and formData.zipCodeInfo > 0
        formData.zipCodeInfo  = {"id": formData.zipCodeInfo}
      formData.main = formData.hasOwnProperty('main')
      @model.set formData
      submitButton = $form.find("#btnSubmit").prop('disabled', true)
      that = @
      @model.sync 'create', @model,
        context: {$submitButton: submitButton}
        error: ->
        headers: { 'Accept-Language': 'es', 'WB-Api-Token': util.retrieveKey(config.apiTokenName) }
        success: ->
          that.model.actualiza()
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
      formData.main = formData.hasOwnProperty('main')
      @model.set formData
      that = @
      submitUpdate = $form.find('.btnUpdate').prop('disabled', true)
      @model.sync 'update', @model,
        context: {$submitUpdate: submitUpdate}
        url: config.apiUrl + "/users/shipping-addresses/" + formData.id + '.json',
        error: ->
        headers:{ 'Accept-Language': 'es', 'WB-Api-Token': util.retrieveKey(config.apiTokenName) }
        success: ->
          that.model.actualiza()
        complete: ->
          this.$submitUpdate.prop('disabled', false)
  
  setCityAndState: ->
     comboSelect = @$('select#wbi-shipping-address-zip-code-info')
     valSelected = comboSelect.val()
     if valSelected
       value = comboSelect.wblocationselect('value')
       @setCityAndStateDefault(value)
     else
       @$('[name="city"]').val('')
       @$('[name="state"]').val('')

  setCityAndStateDefault: (value)->
    if value.id
     @$('[name="city"]').val(value.city)
     @$('[name="state"]').val(value.state)

  attach: ->
    super
    that = @
    $editForms = @$("form.shippingEditAddress")
    @$el.find('[name=zipCodeInfo]').wblocationselect()
    $editForms.each ->
      $form = that.$(this)
      $select = $form.find('.select')
      $zipCode = $form.find('.zipCode')
      $zipCodeExtra = $form.find('.zipCodeInfoExtra')

      #zipCode(Winbits.$).find $zipCode.val(), $select, $zipCodeExtra.val()
      #unless $zipCode.val().length < 5
      #  vendor.customSelect($select)

    $form = @$el.find('form#shippingNewAddress')
    #vendor.customSelect($form.find(".select"))

    $editForms.add($form).each ->
      Winbits.$(@).validate
        debug: true
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
          lastName2:
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
          indications:
            required: true
          zipCode:
            required: true
            minlength: 5
            digits: true
          zipCodeInfo:
            zipCodeDoesNotExist: true
            required: (e) ->
              $zipCodeInfo = Winbits.$(e)
              $form = $zipCodeInfo.closest 'form'
              if $form.find('[name=location]').is(':hidden')
                $zipCode = $form.find('[name=zipCode]')
                not $zipCode.val() or (not $zipCodeInfo.val() and $zipCodeInfo.children().length > 1)
              else
                false
          location:
            required: '[name=location]:visible'
            minlength: 2
          county:
            required: '[name=location]:visible'
            minlength: 2
          state:
            required: '[name=location]:visible'
            minlength: 2

    $shippingAddresses = @$el.find('li.wb-shipping-address')
    $shippingAddresses.first().addClass('shippingSelected') if $shippingAddresses.filter('.shippingSelected').length is 0

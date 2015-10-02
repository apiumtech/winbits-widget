'use strict'

View = require 'views/base/view'
utils = require 'lib/util'
EventBroker = require 'chaplin/lib/event_broker'

module.exports = class EditNewShippingAddressView extends View
  container: '#wbi-edit-shipping-address-container'

  if utils.isMobile()
    template = require 'views/checkout/shipping-addresses/templates/mobile/edit-new-shipping-address'
  else
    template = require 'views/checkout/shipping-addresses/templates/edit-new-shipping-address'

  template: template
  initialize: ->
    super
  
  attach: ->
    super
    @delegate 'click', '#wbi-edit-shipping-address-submit-btn', @doSaveShippingAddress
    @delegate 'click', '#wbi-add-shipping-address-cancel-btn', @showShippingAddressesView
#    @$('.requiredField').requiredField()
    @$('#wbi-edit-shipping-address-form').customCheckbox()
    @$('[name=zipCodeInfo]').wblocationselect().on "change", Winbits.$.proxy @setCityAndState, @
    @$('#wbi-edit-shipping-address-form').validate
      errorElement: 'label',
      errorPlacement: ($error, $element) ->
        if $element.attr("name") in ["externalNumber"]
          $error.appendTo $element.parent()
        else if $element.attr("name") in ["zipCodeInfo"]
          $error.appendTo $element.parent()
        else
          $error.insertAfter $element
      rules:
        firstName:
          required: yes
          minlength: 2
        lastName:
          required: yes
          minlength: 2
        lastName2:
          minlength: 2
        street:
          required: yes
        phone:
          required: yes
          wbiPhone:yes
          minlength: 10
        indications:
          required: yes
        externalNumber:
          minlength: 1
          required: yes
        internalNumber:
          minlength: 1
        state:
          required: yes
        city:
          required: yes
        zipCode:
          minlength:5
          digits:yes
          required: yes
          zipCodeDoesNotExist:yes
        zipCodeInfo:
          required: yes
          wbiSelectInfo: yes
        location:
          wbiLocation: yes
    
    @validFormAfterAttach()

  validFormAfterAttach: ->
    window.setTimeout @validFormAfter, 275

  validFormAfter: ->
    $form =Winbits.$('#wbi-edit-shipping-address-form')
    if $form.is(':visible')
      $form.valid()
      
  setCityAndState: ->
     comboSelect = @$('#wbi-shipping-address-zip-code-info')
     valSelected = comboSelect.val()
     if valSelected
       value = @selectZipCodeInfo(comboSelect, valSelected)
       @setCityAndStateDefault value
     else
       @$('[name="county"]').val('')
       @$('[name="state"]').val('')

  selectZipCodeInfo:(comboSelect,value)->
    if value > 0
      return comboSelect.wblocationselect('value')
    else
      return comboSelect.wblocationselect('firstValue')

  setCityAndStateDefault: (value)->
    @$('[name="county"]').val(value.county)
    @$('[name="state"]').val(value.state)


  doSaveShippingAddress: (e)->
    e.stopImmediatePropagation()
    e.preventDefault()
    itemId = Winbits.$("#wbi-edit-shipping-address-form").data('id')
    $form =  @$el.find("#wbi-edit-shipping-address-form")
    @$('.errorDiv').css('display':'none')
    if($form.valid())
      utils.showAjaxIndicator('Actualizando dirección de envío...')
      @checkZipCodeInfo()
      data = utils.serializeForm $form
      @model.requestSaveEditShippingAddress(itemId,data, context: @)
      .done(@successSaveEditShippingAddress)
      .fail(@errorSaveEditShippingAddress)

  checkZipCodeInfo: ->
    zipCodeInfo =@$('select#wbi-shipping-address-zip-code-info').wblocationselect('value')
    if zipCodeInfo.locationName
      @$('[name="location"]').val zipCodeInfo.locationName

  successSaveEditShippingAddress:()->
    Winbits.$('.errorDiv').css('display':'none')
    utils.hideAjaxIndicator()
    @publishEvent 'addresses-changed'

  errorSaveEditShippingAddress:(xhr, textStatus)->
    error = utils.safeParse(xhr.responseText)
    message = if error then error.meta.message else textStatus
    @$('.errorDiv p').text(message).parent().css('display':'block')
  
  showShippingAddressesView:(e) ->
    e.stopImmediatePropagation()
    e.preventDefault()
    Winbits.$('.errorDiv').css('display':'none')
    Winbits.$('#wbi-edit-shipping-address-container').html('')  
    Winbits.$('#wbi-edit-shipping-address-container').hide()
    Winbits.$('#wbi-shipping-addresses-view').show()

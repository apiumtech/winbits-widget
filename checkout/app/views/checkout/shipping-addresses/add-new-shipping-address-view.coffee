'use strict'

View = require 'views/base/view'
utils = require 'lib/util'

module.exports = class AddNewShippingAddressView extends View
  container: '#wbi-shipping-new-address-container'

  if utils.isMobile()
    template = require 'views/checkout/shipping-addresses/templates/mobile/add-new-shipping-address'
  else
    template = require 'views/checkout/shipping-addresses/templates/add-new-shipping-address'

  template: template

  initialize: ->
    super
  
  render: ->
    super
  
  attach: ->
    super
    @delegate 'click', '#wbi-add-shipping-address-submit-btn', @doSaveShippingAddress
    @delegate 'click', '#wbi-add-shipping-address-cancel-btn', @showShippingAddressesView
#    @$('.requiredField').requiredField()
    @$('#wbi-shipping-new-address-form').customCheckbox()
    @$('[name=zipCodeInfo]').wblocationselect().on "change", Winbits.$.proxy @setCityAndState, @
    @$('#wbi-shipping-new-address-form').validate
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

  setCityAndState: ->
     comboSelect = @$('select#wbi-shipping-address-zip-code-info')
     valSelected = comboSelect.val()
     if valSelected
       value = comboSelect.wblocationselect('value')
       @setCityAndStateDefault value
     else
       @$('[name="county"]').val('')
       @$('[name="state"]').val('')


  setCityAndStateDefault: (value)->
    if value.id
     @$('[name="county"]').val(value.county)
     @$('[name="state"]').val(value.state)


  doSaveShippingAddress:(e) ->
    e.stopImmediatePropagation()
    e.preventDefault()
    $form =  @$el.find("#wbi-shipping-new-address-form")
    @$('.errorDiv').css('display':'none')
    if($form.valid())
      data = utils.serializeForm $form
      $form.find("#wbi-add-shipping-address-submit-btn").prop('disabled', true)
      utils.showAjaxIndicator('Agregando dirección de envío...')
      @model.requestSaveNewShippingAddress(data, context: @)
      .done(@successAddingShippingAddresses)
      .fail(@errorSaveNewShippingAddress)
      .always(@completeSaveNewShippingAddress)
  
  checkZipCodeInfo: ->
    zipCodeInfo =@$('#wbi-shipping-address-zip-code-info').wblocationselect('value')
    if not zipCodeInfo.state
      console.log ["Zip code info in other..."]
      @$('[name="city"]').val city
      @$('[name="state"]').val state

  showShippingAddressesView:()->
    $form = @$('#wbi-shipping-new-address-form')
    utils.justResetForm($form)
    Winbits.$('#wbi-shipping-new-address-container').hide()  
    Winbits.$('#wbi-shipping-addresses-view').show()
  
  completeSaveNewShippingAddress: ->
    utils.hideAjaxIndicator()

  successAddingShippingAddresses:() ->
    @publishEvent 'addresses-changed' 

  errorSaveNewShippingAddress:(xhr, textStatus)->
    error = utils.safeParse(xhr.responseText)
    message = if error then error.meta.message else textStatus
    @$('.errorDiv p').text(message).parent().css('display':'block')
  

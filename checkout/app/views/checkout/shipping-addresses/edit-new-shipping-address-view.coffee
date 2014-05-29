'use strict'

View = require 'views/base/view'
utils = require 'lib/util'
EventBroker = require 'chaplin/lib/event_broker'

module.exports = class EditNewShippingAddressView extends View
  container: '#wbi-edit-shipping-address-container'
  template: require 'views/checkout/shipping-addresses/templates/edit-new-shipping-address'

  initialize: ->
    super
  
  attach: ->
    super
    @delegate 'click', '#wbi-edit-shipping-address-submit-btn', @doSaveShippingAddress
    @delegate 'click', '#wbi-add-shipping-address-cancel-btn', @showShippingAddressesView
    @$('.requiredField').requiredField()
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

  setCityAndState: ->
     comboSelect = @$('#wbi-shipping-address-zip-code-info')
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


  doSaveShippingAddress: (e)->
    e.stopImmediatePropagation()
    e.preventDefault()
    console.log 'updatiiiing'
    itemId = Winbits.$("#wbi-edit-shipping-address-form").data('id')
    $form =  @$el.find("#wbi-edit-shipping-address-form")
    @$('.errorDiv').css('display':'none')
    if($form.valid())
        #@$('#wbi-edit-shipping-thanks-div').show()
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
    EventBroker.publishEvent 'updateShippingAddressView'

  errorSaveEditShippingAddress:(xhr, textStatus)->
    #@$('#wbi-edit-shipping-thanks-div').hide()
    error = utils.safeParse(xhr.responseText)
    message = if error then error.meta.message else textStatus
    @$('.errorDiv p').text(message).parent().css('display':'block')
  
  showShippingAddressesView:(e) ->
    e.stopImmediatePropagation()
    e.preventDefault()
    Winbits.$('#wbi-edit-shipping-address-container').html('')  
    Winbits.$('#wbi-edit-shipping-address-container').hide()
    Winbits.$('#wbi-shipping-addresses-view').show()


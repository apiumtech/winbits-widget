'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class AddNewShippingAddressView extends View
  container: '#wbi-edit-shipping-address-container'
  template: require './templates/edit-shipping-address'

  initialize: ->
    super
    @delegate 'click', '#wbi-edit-shipping-address-submit-btn', @doSaveShippingAddress

  attach: ->
    super
    @$('.requiredField').requiredField()
    @$('#wbi-edit-shipping-address-form').customCheckbox()
    @$('[name=zipCodeInfo]').wblocationselect().on "change", $.proxy @setCityAndState, @
    @$('#wbi-edit-shipping-address-form').validate
      errorElement: 'span',
      errorPlacement: ($error, $element) ->
        if $element.attr("name") in ["externalNumber"]
          $error.appendTo $element.parent().parent()
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
       @setCityAndStateDefault(value)
     else
       @$('[name="city"]').val('')
       @$('[name="state"]').val('')


  setCityAndStateDefault: (value)->
    if value.id
     @$('[name="city"]').val(value.city)
     @$('[name="state"]').val(value.state)


  doSaveShippingAddress: (e)->
    itemId = $(e.currentTarget).closest('form#wbi-edit-shipping-address-form').data("id")
    $form =  @$el.find("#wbi-edit-shipping-address-form")
    @$('.errorDiv').css('display':'none')
    if($form.valid())
      @$('#wbi-edit-shipping-thanks-div').show()
      @checkZipCodeInfo()
      data = utils.serializeForm $form
      @model.requestSaveEditShippingAddress(itemId,data, context: @)
      .done(@successSaveEditShippingAddress)
      .fail(@errorSaveEditShippingAddress)

  checkZipCodeInfo:()->
    zipCodeInfo =@$('select#wbi-shipping-address-zip-code-info').wblocationselect('value')
    console.log ["check zip Code Info", zipCodeInfo]
    if zipCodeInfo.locationName
      @$('[name="location"]').val zipCodeInfo.locationName

  successSaveEditShippingAddress:()->
    @$('#wbi-edit-shipping-address-process').hide()
    @$('#wbi-edit-shipping-address-done').show()

  errorSaveEditShippingAddress:(xhr, textStatus)->
    @$('#wbi-edit-shipping-thanks-div').hide()
    error = utils.safeParse(xhr.responseText)
    message = if error then error.meta.message else textStatus
    @$('.errorDiv p').text(message).parent().css('display':'block')
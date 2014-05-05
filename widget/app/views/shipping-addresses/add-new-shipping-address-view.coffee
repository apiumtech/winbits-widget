'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class AddNewShippingAddressView extends View
  container: '#wbi-shipping-new-address-container'
  template: require './templates/add-new-shipping-address'
  noWrap: yes

  initialize: ->
    super
    @delegate 'click', '#wbi-add-shipping-address-submit-btn', @doSaveShippingAddress

  attach: ->
    super
    @$('.requiredField').requiredField()
    @$('[name=zipCodeInfo]').wblocationselect().on "change", $.proxy @setCityAndState, @
    @$('#wbi-shipping-new-address-form').validate
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
       @setCityAndStateDefault value
     else
       @$('[name="city"]').val('')
       @$('[name="state"]').val('')


  setCityAndStateDefault: (value)->
    if value.id
     @$('[name="city"]').val(value.city)
     @$('[name="state"]').val(value.state)


  doSaveShippingAddress: ->
    $form =  @$el.find("#wbi-shipping-new-address-form")
    @$('.errorDiv').css('display':'none')
    if($form.valid())
      @$('#wbi-shipping-thanks-div').show()
      data = utils.serializeForm $form
      @model.requestSaveNewShippingAddress(data, context: @)
      .done(@successSaveNewShippingAddress)
      .fail(@errorSaveNewShippingAddress)

  successSaveNewShippingAddress:()->
    @$('#wbi-shipping-address-process').hide()
    @$('#wbi-shipping-address-done').show()

  errorSaveNewShippingAddress:(xhr, textStatus)->
    @$('#wbi-shipping-thanks-div').hide()
    error = utils.safeParse(xhr.responseText)
    message = if error then error.meta.message else textStatus
    @$('.errorDiv p').text(message).parent().css('display':'block')
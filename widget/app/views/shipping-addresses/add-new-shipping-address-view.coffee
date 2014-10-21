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
#    @$('.requiredField').requiredField()
    @$('#wbi-shipping-new-address-form').customCheckbox()
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

  doSaveShippingAddress: ->
    $form =  @$el.find("#wbi-shipping-new-address-form")
    @$('.errorDiv').css('display':'none')
    if($form.valid())
      utils.showAjaxLoading()
      data = utils.serializeForm $form
      @model.requestSaveNewShippingAddress(data, context: @)
      .done(@successSaveNewShippingAddress)
      .fail(@errorSaveNewShippingAddress)

  successSaveNewShippingAddress:()->
    utils.hideAjaxLoading()
    options =
      context: @
      icon: 'iconFont-ok'
      onClosed: -> @publishEvent 'addresses-changed'
    utils.showMessageModal('La Dirección de envío ha sido agregada correctamente.', options)

  errorSaveNewShippingAddress:(xhr, textStatus)->
    error = utils.safeParse(xhr.responseText)
    message = if error then error.meta.message else textStatus
    @$('.errorDiv p').text(message).parent().css('display':'block')

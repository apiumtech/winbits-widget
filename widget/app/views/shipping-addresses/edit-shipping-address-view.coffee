'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class EditShippingAddressView extends View
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

    @validFormAfterAttach()

  validFormAfterAttach: ->
    window.setTimeout @validFormAfter, 275

  validFormAfter: ->
    $form =$('#wbi-edit-shipping-address-form')
    if $form.is(':visible')
      $form.valid()

  setCityAndState: ->
     comboSelect = @$('select#wbi-shipping-address-zip-code-info')
     valSelected = comboSelect.val()
     if valSelected
       value = @selectZipCodeInfo(comboSelect, valSelected)
       @setCityAndStateDefault value
     else
       @$('[name="city"]').val('')
       @$('[name="state"]').val('')

  selectZipCodeInfo:(comboSelect,value)->
    if value > 0
      return comboSelect.wblocationselect('value')
    else
      return comboSelect.wblocationselect('firstValue')

  setCityAndStateDefault: (value)->
    @$('[name="city"]').val(value.city)
    @$('[name="state"]').val(value.state)


  doSaveShippingAddress: (e)->
    itemId = $(e.currentTarget).closest('form#wbi-edit-shipping-address-form').data("id")
    $form =  @$el.find("#wbi-edit-shipping-address-form")
    @$('.errorDiv').css('display':'none')
    if($form.valid())
      utils.showAjaxLoading()
      @checkZipCodeInfo()
      data = utils.serializeForm $form
      @model.requestSaveEditShippingAddress(itemId,data, context: @)
      .done(@successSaveEditShippingAddress)
      .fail(@errorSaveEditShippingAddress)
      .always(@completeSaveEditShippingAddress)

  checkZipCodeInfo: ->
    zipCodeInfo =@$('select#wbi-shipping-address-zip-code-info').wblocationselect('value')
    if zipCodeInfo.locationName
      @$('[name="location"]').val zipCodeInfo.locationName


  completeSaveEditShippingAddress: ->
    utils.hideAjaxLoading()


  successSaveEditShippingAddress:()->
    @publishEvent 'addresses-changed'
    options =
      context: @
      icon: 'iconFont-ok'
      onClosed: @$('#wbi-edit-shipping-address-cancel').click()
    utils.showMessageModal('La Dirección de envio ha sido actualizada correctamente.', options)


  errorSaveEditShippingAddress:(xhr, textStatus)->
    error = utils.safeParse(xhr.responseText)
    message = if error then error.meta.message else textStatus
#    @$('.errorDiv p').text(message).parent().css('display':'block')
    utils.showError(message)
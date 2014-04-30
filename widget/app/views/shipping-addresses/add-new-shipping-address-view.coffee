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
#    @delegate 'change', 'select#wbi-shipping-address-zip-code-info', @setCityAndState
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
        street:
          required: yes
        zipCode:
          required: yes
          minlength:5
          digits:yes
          zipCodeDoesNotExist:yes
        phone:
          required: yes
          wbiPhone:yes
          minlength: 10
        indications:
          required: yes
        betweenStreets:
          required: yes
        externalNumber:
          required: yes
        state:
          required: yes
        city:
          required: yes
        zipCodeInfo:
          required: yes
          wbiSelectInfo: yes

  doSaveShippingAddress:(e)->
    e.preventDefault()
    $form =  @$el.find("#wbi-shipping-new-address-form")
    if($form.valid())
       @$('#wbi-shipping-thanks-div').show()

  setCityAndState: () ->
     value = @$('select#wbi-shipping-address-zip-code-info').wblocationselect('value')
     @$('[name="city"]').val(value.city)
     @$('[name="state"]').val(value.state)
     console.log ["Value", value]
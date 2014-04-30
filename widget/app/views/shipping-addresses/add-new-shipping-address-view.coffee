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
    @$('#wbi-shipping-new-address-form').validate
      errorElement: 'span',
      errorPlacement: ($error, $element) ->
        if $element.attr("name") in ["externalNumber"]
          $error.appendTo $element.parent()
        else
          $error.insertAfter $element
      groups:
        locationNumber: ' externalNumber internalNumber '
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

  doSaveShippingAddress:(e)->
    e.preventDefault()
    $form =  @$el.find("#wbi-shipping-new-address-form")
    if($form.valid())
       @$('#wbi-shipping-thanks-div').show()
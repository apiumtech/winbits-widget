'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class PersonalDataView extends View
  container: '#wb-profile'
  id : 'wbi-personal-data'
  template: require './templates/personal-data'

  initialize: ->
    super
    @listenTo @model, 'change', @render
    @delegate 'click', '#wbi-update-profile-btn', @updateProfile

  attach: ->
    super
    @$el.prop 'class', 'column miCuenta-profile'
    @$('.divGender').customRadio()
#    @$('.requiredField').requiredField()
    @$('[name=zipCodeInfo]').wblocationselect()
    @$('#wbi-personal-data-form').validate
      ignore : ''
      errorElement: 'span',
      errorPlacement: ($error, $element) ->
        if $element.attr("name") in ["wbi-birthdate-day", "wbi-birthdate-month", "wbi-birthdate-year"]
          $error.appendTo $element.parent()
        else if $element.attr("name") in ["gender", "zipCodeInfo"]
          $error.appendTo $element.parent().parent()
        else
          $error.insertAfter $element
      groups:
        birthDate: ' wbi-birthdate-day wbi-birthdate-month wbi-birthdate-year'
      rules:
        name:
          required: yes
          minlength:2
        lastName:
          required: yes
          minlength: 2
        'wbi-birthdate-day':
          required: yes
          validateDate: yes
        'wbi-birthdate-month':
          required: yes
          validateDate: yes
        'wbi-birthdate-year':
          required: yes
          validateDate: yes
        phone:
          required: @model.fieldIsRequired('phone')
          wbiPhone: yes
#        phone:
#          required: @model.fieldIsRequired('phone')
#          wbiPhone: yes
        zipCode:
          required: yes
          minlength: 5
          digits:yes
          zipCodeDoesNotExist:yes
        gender:
          required: yes
        location:
          wbiLocation: yes
        zipCodeInfo:
          wbiSelectInfo: yes


  updateProfile : (e) ->
    $form = @$('#wbi-personal-data-form')
    data = utils.serializeProfileForm $form
    if($form.valid())
      submitButton = @$(e.currentTarget).prop('disabled', yes)
      utils.showAjaxLoading()
      @model.requestUpdateProfile(data, context: @)
      .done(@doUpdateProfileSuccess)
      .fail(@doUpdateProfileError)
      .always ->
             utils.hideAjaxLoading()
             submitButton.prop('disabled', no)

  #
  #
  #
  #
  doUpdateProfileSuccess: (data) ->
    utils.updateProfile(data, {url:'wb-profile'})


  doUpdateProfileError: (xhr, textStatus)->
    error = utils.safeParse(xhr.responseText)
    messageText = "Error guardando el registro #{textStatus}"
    message = if error then error.meta.message else messageText
    options = value: "Cerrar", title:'Error', onClosed: utils.redirectToLoggedInHome()
    utils.showMessageModal(message, options)


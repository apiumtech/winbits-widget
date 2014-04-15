'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class PersonalDataView extends View
  container: '#wbi-my-profile'
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
    @$('.requiredField').requiredField()
    @$('#wbi-personal-data-form').validate
      errorElement: 'span',
      errorPlacement: ($error, $element) ->
        if $element.attr("name") in ["wbi-birthdate-day", "wbi-birthdate-month", "wbi-birthdate-year"]
          $error.appendTo $element.parent()
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
#          digits: yes
          validateDate: yes
        'wbi-birthdate-month':
#          digits: yes
          validateDate: yes
        'wbi-birthdate-year':
#          digits: yes
          validateDate: yes

  updateProfile : (e) ->
    $form = @$('#wbi-personal-data-form')
    data = utils.serializeProfileForm $form
    if($form.valid())
      submitButton = @$(e.currentTarget).prop('disabled', yes)
      @model.requestUpdateProfile(data, context: @)
      .done(@doUpdateProfileSuccess)
      .fail(@doUpdateProfileError)
      .always -> submitButton.prop('disabled', no)

  doUpdateProfileSuccess: (data) ->
    @publishEvent 'profile-changed', data
    mediator.data.set 'login-data', data.response


  doUpdateProfileError: (xhr, textStatus)->
    error = utils.safeParse(xhr.responseText)
    messageText = "Error guardando el registro #{textStatus}"
    message = if error then error.meta.message else messageText
    options = value: "Cerrar", title:'Error', onClosed: utils.redirectToLoggedInHome()
    utils.showMessageModal(message, options)

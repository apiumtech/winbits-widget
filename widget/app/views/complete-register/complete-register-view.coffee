View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class CompleteRegisterView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-complete-register-modal'
  template: require './templates/complete-register'

  initialize: ->
    super
    @delegate 'click', '#wbi-complete-register-btn', @completeRegister
    @delegate 'click', '#wbi-complete-register-after-link', utils.closeMessageModal

  attach: ->
    super
    @showAsModal()
    @$('.divGender').customRadio()
    @$('[name=zipCodeInfo]').wblocationselect()
    @$('#wbi-complete-register-form').validate
      ignore:''
      errorPlacement: ($error, $element) ->
        if $element.attr("name") in ["wbi-birthdate-day", "wbi-birthdate-month", "wbi-birthdate-year"]
          $error.appendTo $element.parent()
        else if $element.attr("name") in ["zipCodeInfo"]
          $error.appendTo $element.parent().parent()
        else
          $error.insertAfter $element
      groups:
        birthDate: ' wbi-birthdate-day wbi-birthdate-month wbi-birthdate-year'
      rules:
        name:
          required: @model.fieldIsRequired('name')
          minlength:2
        lastName:
          required: @model.fieldIsRequired('lastName')
          minlength: 2
        'wbi-birthdate-day':
          required: @model.fieldIsRequired('birthdate')
          validateDate: yes
        'wbi-birthdate-month':
          required: @model.fieldIsRequired('birthdate')
          validateDate: yes
        'wbi-birthdate-year':
          required: @model.fieldIsRequired('birthdate')
          validateDate: yes
        phone:
          required: @model.fieldIsRequired('phone')
          wbiPhone: yes
        zipcode:
          required: @model.fieldIsRequired('zipCode')
          minlength: 5
          digits:yes
          zipCodeDoesNotExist:yes
        location:
          wbiLocation: yes
        gender:
          required: @model.fieldIsRequired('gender')
        zipCodeInfo:
          wbiSelectInfo: yes

  showAsModal: ->
    $ ->
      $('<a>').wbfancybox(href: '#wbi-complete-register-modal', onClosed: -> utils.redirectTo controller:'home', action:'index').click()

  completeRegister: (e)->
    e.preventDefault()
    $form = @$('#wbi-complete-register-form')
    data = utils.serializeProfileForm $form
    if($form.valid())
      submitButton = @$(e.currentTarget).prop('disabled', yes)
      @model.requestUpdateProfile(data, context: @)
        .done(@doCompleteRegisterSuccess)
        .fail(@doCompleteRegisterError)
        .always -> submitButton.prop('disabled', no)

  doCompleteRegisterSuccess: (data) ->
    utils.updateProfile(data)
    utils.closeMessageModal()


  doCompleteRegisterError: (xhr, textStatus)->
    error = utils.safeParse(xhr.responseText)
    messageText = "Error guardando el registro #{textStatus}"
    message = if error then error.meta.message else messageText
    options = value: "Cerrar", title:'Error', onClosed: utils.redirectToLoggedInHome()
    utils.showMessageModal(message, options)



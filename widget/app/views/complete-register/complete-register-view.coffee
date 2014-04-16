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
    @delegate 'click', '#wbi-complete-register-after-link', -> $.fancybox.close()

  attach: ->
    super
    @showAsModal()
    @$('.divGender').customRadio()
    @$('[name=zipCodeInfo]').wblocationselect()
    @$('#wbi-complete-register-form').validate
      rules:
        name:
          minlength:2
        lastName:
          minlength: 2
        zipCode:
          minlength:5
          digits:yes
        phone:
          wbiPhone:yes

  showAsModal: ->
    $ ->
      $('<a>').wbfancybox(href: '#wbi-complete-register-modal', onClosed: -> utils.redirectTo controller:'home', action:'index').click()

  completeRegister: (e)->
    $form = @$('#wbi-complete-register-form')
    data = utils.serializeProfileForm $form
    if($form.valid())
      submitButton = @$(e.currentTarget).prop('disabled', yes)
      @model.requestUpdateProfile(data, context: @)
        .done(@doCompleteRegisterSuccess)
        .fail(@doCompleteRegisterError)
        .always -> submitButton.prop('disabled', no)

  doCompleteRegisterSuccess: (data) ->
    @publishEvent 'profile-changed', data
    mediator.data.set 'login-data', data.response
    $.fancybox.close()


  doCompleteRegisterError: (xhr, textStatus)->
    error = utils.safeParse(xhr.responseText)
    messageText = "Error guardando el registro #{textStatus}"
    message = if error then error.meta.message else messageText
    options = value: "Cerrar", title:'Error', onClosed: utils.redirectToLoggedInHome()
    utils.showMessageModal(message, options)

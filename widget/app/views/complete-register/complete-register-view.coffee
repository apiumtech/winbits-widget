View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$
env = Winbits.env

module.exports = class CompleteRegisterView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-complete-register-modal'
  template: require './templates/complete-register'

  initialize: ->
    super
    @delegate 'click', '#wbi-complete-register-btn', @completeRegister

  attach: ->
    super
    @showAsModal()
    @$('.divGender').customRadio()
    @$('#wbi-complere-register-form').validate
      rules:
        name:
          minlength:2
        lastName:
          minlength: true
        zipCode:
          minlength:5
        phone:
          minlength:8



  showAsModal: ->
    $('<a>').wbfancybox(href: '#wbi-complete-register-modal', onClosed: -> utils.redirectToLoggedInHome()).click()


  completeRegister: ->
    data = utils.serializeForm @$('#wbi-complete-register-form')
    @model.requestCompleteRegister(data)
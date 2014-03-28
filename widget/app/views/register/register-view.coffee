View = require 'views/base/view'
utils = require 'lib/utils'
config = require 'config'
$ = Winbits.$

module.exports = class ModalRegisterView extends View
  container: 'header'
  id: 'wbi-register-modal'
  className: 'wbc-hide'
  template: require './templates/register'

  initialize: ->
    super
    @delegate 'click', '#wbi-login-link', -> utils.redirectTo controller: 'login', action: 'index'
    @delegate 'click', '#wbi-register-button', @register

  attach: ->
    super
    @showAsModal()
    @$('#wbi-register-form').validate
      rules:
        'email':
          required: true
          email: true
        'password':
          required: true
        'againPassword':
          required:true
#          equalTo: true

  showAsModal: ->
    $('<a>').wbfancybox(href: '#wbi-register-modal', onClosed: -> utils.redirectToNotLoggedInHome()).click()


  register: (e)->
    e.preventDefault()
    console.log "RegisterView#register"
    $form =  @$el.find("#wbi-register-form")
    that = @
    formData = verticalId: config.verticalId
    formData = utils.serializeForm($form, formData)
    console.log ["Register Data", formData]

    if utils.validateForm($form)
      submitButton = @$(e.currentTarget).prop('disabled', true)
      utils.ajaxRequest( config.apiUrl + "/affiliation/register.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(formData)
        xhrFields:
          withCredentials: true
        context: {$submitButton: submitButton}
        headers:
          "Accept-Language": "es"
        success: (data) ->
          console.log "Request Success!"
          console.log ["data", data]
          w$('.modal').modal 'hide'
          that.publishEvent "showConfirmation"

        error: (xhr) ->
          console.log xhr
          error = JSON.parse(xhr.responseText)
          that.renderRegisterFormErrors $form, error

        complete: ->
          console.log "Request Completed!"
          this.$submitButton.prop('disabled', false)
      )
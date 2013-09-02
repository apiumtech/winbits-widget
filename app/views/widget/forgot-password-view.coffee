template = require 'views/templates/widget/forgot-password'
View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'

module.exports = class ForgotPasswordView extends View
  autoRender: yes
  container: '#forgot-password-modal-body'
  template: template

  render: ->
    super

  initialize: ->
    super
    @delegate 'click', '#forgotPasswordSubmit', @sendEmail
    @delegate 'click', '#goToRegisterLink', @goToRegisterLink
    @delegate 'click', "#loginByFacebookLink", @loginByFacebookLink
    @delegate 'click', "#goToLoginLink", @goToLoginLink

  attach: ()->
    super

  sendEmail: (e) ->
    e.preventDefault()
    that = @
    $form = @$el.find("#recoverPsw")
    console.log $form.valid()
    if $form.valid()
      console.log "Recover password"
      formData = util.serializeForm($form)
      Backbone.$.ajax config.apiUrl + "/affiliation/password/recover.json",
        data: JSON.stringify(formData)
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        xhrFields:
          withCredentials: true

        headers:
          "Accept-Language": "es"
          "WB-Api-Token":  util.getCookie(config.apiTokenName)

        success: (data) ->
          console.log ["RecoverPasswordStatus.json Success!", data]
          that.publishEvent 'cleanModal'
          alert data.response.message

        error: (xhr, textStatus, errorThrown) ->
          console.log "RecoverPasswordStatus.json Error!"
          error = JSON.parse(xhr.responseText)
          alert error.meta.message
          that.publishEvent 'cleanModal'

        complete: ->
          console.log "RecoverPasswordStatus.json Completed!"

  goToRegisterLink: (e) ->
    e.preventDefault()
    @publishEvent 'showRegister'

  loginByFacebookLink: (e) ->
    console.log('Enviando a facebook login')
    @publishEvent 'loginByFacebookEvent', e

  goToLoginLink: (e) ->
    @publishEvent 'showLogin', e
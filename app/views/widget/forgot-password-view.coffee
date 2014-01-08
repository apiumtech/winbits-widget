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
    @$el.find('#recoverPsw').validate
      rules:
        email:
          required: true
          email: true

  sendEmail: (e) ->
    e.preventDefault()
    that = @
    $form = @$el.find("#recoverPsw")
    console.log $form.valid()
    if $form.valid()
      console.log "Recover password"
      formData = util.serializeForm($form)
      formData.verticalId = config.verticalId
      submitButton = @$(e.currentTarget).prop('disabled', true)
      Backbone.$.ajax config.apiUrl + "/affiliation/password/recover.json",
        data: JSON.stringify(formData)
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        xhrFields:
          withCredentials: true
        context: {$submitButton: submitButton}
        headers:
          "Accept-Language": "es"
          "WB-Api-Token":  util.retrieveKey(config.apiTokenName)

        success: (data) ->
          console.log ["RecoverPasswordStatus.json Success!", data]
          that.publishEvent 'cleanModal'
          that.publishEvent 'showMessageConfirm', "#wbi-recover-password-confirm-modal"

        error: (xhr, textStatus, errorThrown) ->
          console.log "RecoverPasswordStatus.json Error!"
          that.publishEvent 'cleanModal'
          util.showAjaxError(xhr.responseText)

        complete: ->
          console.log "RecoverPasswordStatus.json Completed!"
          this.$submitButton.prop('disabled', false)

  goToRegisterLink: (e) ->
    e.preventDefault()
    @publishEvent 'showRegister'

  loginByFacebookLink: (e) ->
    console.log('Enviando a facebook login')
    @publishEvent 'loginByFacebookEvent', e

  goToLoginLink: (e) ->
    @publishEvent 'showLogin', e
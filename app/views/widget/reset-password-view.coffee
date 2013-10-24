template = require 'views/templates/widget/reset-password'
View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'

module.exports = class ResetPasswordView extends View
  autoRender: yes
  container: '#wbi-reset-password-modal-body'
  template: template

  render: ->
    super

  initialize: ->
    super
    @delegate 'click', '#wbi-reset-form-login-btn', @resetPassword

  attach: ()->
    super
    @$el.find('form#wbi-reset-login-form').validate rules:
      password:
        required: true
        minlength: 5
      passwordConfirm:
        required: true
        minlength: 5
        equalTo: '#wbi-reset-new-password'
    params = util.getUrlParams()
    console.log ['ResetPassword#attach', params.salt ]
    if params._wb_pr is "true"
      @publishEvent 'updateResetModel', {salt: params.salt}
      @publishEvent 'showResetPassword'
      console.log ['ResetPassword#pr', params._wb_pr ]


  resetPassword: (e) ->
    e.preventDefault()
    that = @
    $form = @$el.find("#wbi-reset-login-form")
    if $form.valid()
      formData = util.serializeForm($form)
      formData.hash = @model.attributes.salt
      submitButton = @$(e.currentTarget).prop('disabled', true)
      Backbone.$.ajax config.apiUrl + "/affiliation/password/reset.json",
        data: JSON.stringify(formData)
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        xhrFields:
          withCredentials: true
        context: {$submitButton: submitButton}
        headers:
          "Accept-Language": "es"
          "WB-Api-Token":  util.getCookie(config.apiTokenName)

        success: (data) ->
          console.log ["Reset Password Status Success!", data]
          that.publishEvent 'cleanModal'
          that.publishEvent 'showMessageConfirm', "#wbi-reset-password-confirm-modal"

        error: (xhr, textStatus, errorThrown) ->
          console.log "Reset Password Status Error!"
          that.publishEvent 'cleanModal'
          util.showAjaxError(xhr.responseText)

        complete: ->
          console.log "Reset Password Status Completed!"
          this.$submitButton.prop('disabled', false)
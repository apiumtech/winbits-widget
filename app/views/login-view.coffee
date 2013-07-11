template = require 'views/templates/login'
View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'
token = require 'lib/token'
mediator = require 'chaplin/mediator'

module.exports = class LoginView extends View
  autoRender: yes
  #className: 'home-page'
  container: '#login-modal-body'
  template: template

  render: ->
    console.log "(>_<)"
    super

  initialize: ->
    super
    @delegate 'click', '#form-login-btn', @doLogin

  doLogin: (e)->
    e.preventDefault()
    e.stopPropagation()
    console.log "Do Login:"
    $form = $(e.currentTarget).parents("form")
    formData = verticalId: config.verticalId
    formData = util.Forms.serializeForm($form, formData)
    console.log ["Login Data", formData]
    that = @
    $.ajax config.apiUrl + "/affiliation/login.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      xhrFields:
        withCredentials: true

      context: $form
      beforeSend: ->
        util.validateForm $form

      headers:
        "Accept-Language": "es"
      success: (data) ->
        console.log "Request Success!"
        console.log ["data", data]
        that.publishEvent "applyLogin", data.response
        #$.fancybox.close()
        #@loginModalPanel.fadeOut()
        $('.modal').modal 'hide'


      error: (xhr, textStatus, errorThrown) ->
        console.log xhr
        error = JSON.parse(xhr.responseText)
        util.renderLoginFormErrors $form, error

      complete: ->
        console.log "Request Completed!"

#todo put this on template
  renderLoginFormErrors : (form, error) ->
    if error.meta.code is "AFER004"
      $resendConfirmLink = $("<a href=\"" + error.response.resendConfirmUrl + "\">Reenviar correo de confirmaci&oacute;n</a>")
      $resendConfirmLink.click (e) ->
        e.preventDefault()
        Winbits.resendConfirmLink $, e.target

      $errorMessageHolder = $("<p>" + error.meta.message + ". <span class=\"link-holder\"></span></p>")
      $errorMessageHolder.find(".link-holder").append $resendConfirmLink
      message = error.message or error.meta.message
      $errors = $form.find(".errors")
      $errors.children().remove()
      $errors.append $errorMessageHolder
    else
      message = error.message or error.meta.message
      $form.find(".errors").html "<p>" + message + "</p>"


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
    formData = util.Forms.serializeForm($, $form, formData)
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

  applyLogin: ($, profile) ->
    console.log "applyLogin"
    mediator.flags.loggedIn = true
    console.log mediator
    #app.checkCompleteRegistration $
    console.log "Logged In"
    token.saveApiToken profile.apiToken
    #app.restoreCart $
    #app.$widgetContainer.find("div.login").hide()
    #app.$widgetContainer.find("div.miCuentaPanel").show()
    app.loadUserProfile $, profile


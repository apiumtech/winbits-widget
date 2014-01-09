template = require 'views/templates/widget/login'
View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'
token = require 'lib/token'
mediator = require 'chaplin/mediator'
vendor = require 'lib/vendor'

module.exports = class LoginView extends View
  autoRender: yes
  #className: 'home-page'
  container: '#login-modal-body'
  template: template

  render: ->
    super

  initialize: ->
    super
    @delegate 'click', '#form-login-btn', @doLogin
    @delegate 'click', '#login-by-facebook', @doLoginFacebook
    @delegate 'click', '#notRegisterLink', @showRegisterModal
    @delegate 'click', '#forgotPasswordLink', @showForgotPasswordModal

    @subscribeEvent 'loginByFacebookEvent', @doLoginFacebook

  attach: ->
    super
    @$el.find('#login-form').validate
      rules:
        email:
          required: true
          email: true
        password:
          required: true
          minlength: 5

  doLogin: (e)->
    e.preventDefault()
    e.stopPropagation()
    $form = @$(e.currentTarget).parents("form")
    formData = verticalId: config.verticalId
    formData = util.serializeForm($form, formData)
    if util.validateForm($form)
      submitButton = @$(e.currentTarget).prop('disabled', true)
      that=@
      util.ajaxRequest( config.apiUrl + "/affiliation/login.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(formData)
        xhrFields:
          withCredentials: true
#        context: {view: @, $submitButton: submitButton}
        headers:
          "Accept-Language": "es"
        success: (data) ->
          that.publishEvent "applyLogin", data.response
          Winbits.$('.modal').modal 'hide'
          if data.response.showRemainder == true
            that.publishEvent 'completeProfileRemainder'
        error: (xhr) ->
          error = JSON.parse(xhr.responseText)
          that.renderLoginFormErrors $form, error
        complete: ->
          submitButton.prop('disabled', false)
      )

#todo put this on template
  renderLoginFormErrors : ($form, error) ->
    if error.meta.code is "AFER004"
      @publishEvent 'userNotConfirmed', error.response.resendConfirmUrl
    else
      message = error.message or error.meta.message
      $form.find(".errors").html "<p>" + message + "</p>"

  doLoginFacebook: (e) ->
    e.preventDefault()
    $ = Winbits.$
    that = @
    fbButton = @$(e.currentTarget).prop('disabled', true)
    popup = window.open(config.apiUrlBase + "/affiliation/facebook-login/connect?verticalId=" + config.verticalId,
        "facebook", "menubar=0,resizable=0,width=800,height=500")
    popup.postMessage
    popup.focus()

    timer = setInterval(->
      if popup.closed
        fbButton.prop('disabled', false)
        clearInterval timer
        $(".modal").modal('hide')
        that.publishEvent 'expressLogin'
    , 1000)

  showRegisterModal: (e) ->
    e.preventDefault()
    @publishEvent 'showRegister'

  showForgotPasswordModal: (e) ->
    e.preventDefault()
    @publishEvent 'showForgotPassword'

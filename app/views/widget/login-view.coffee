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
  utms: {'::::':"ppp" }

  render: ->
    super

  initialize: ->
    super
    @delegate 'click', '#form-login-btn', @doLogin
    @delegate 'click', '#login-by-facebook', @doLoginFacebook
    @delegate 'click', '#notRegisterLink', @showRegisterModal
    @delegate 'click', '#forgotPasswordLink', @showForgotPasswordModal

    @subscribeEvent 'loginByFacebookEvent', @doLoginFacebook
    @subscribeEvent 'getUtms', @getUtms

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
    utm_data = Winbits.$.parseJSON(util.retrieveKey("_wb_utm_params"))
    formData[key] = value for key, value of utm_data
    formData = util.serializeForm($form, formData)
    #parseJSON util.retrieveKey("_wb_utm_params")
    console.log ["Ya en login", util.retrieveKey("_wb_utm_params")]

    if util.validateForm($form)
      submitButton = @$(e.currentTarget).prop('disabled', true)
      Backbone.$.ajax config.apiUrl + "/affiliation/login.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(formData)
        xhrFields:
          withCredentials: true
        context: {view: @, $submitButton: submitButton}
        headers:
          "Accept-Language": "es"
        success: (data) ->
          @view.publishEvent "applyLogin", data.response
          Backbone.$('.modal').modal 'hide'
          if data.response.showRemainder == true
            @view.publishEvent 'completeProfileRemainder'

        error: (xhr) ->
          error = JSON.parse(xhr.responseText)
          @view.renderLoginFormErrors $form, error

        complete: ->
          @$submitButton.prop('disabled', false)

#todo put this on template
  renderLoginFormErrors : ($form, error) ->
    if error.meta.code is "AFER004"
      @publishEvent 'userNotConfirmed', error.response.resendConfirmUrl
    else
      message = error.message or error.meta.message
      $form.find(".errors").html "<p>" + message + "</p>"

  doLoginFacebook: (e) ->
    e.preventDefault()
    $ = Backbone.$
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

  getUtms: (e) ->
    Winbits.rpc.getUtms(
        (success) ->
            @utms= success
            $form = @$(e.currentTarget).parents("form")
            console.log ["success", success, @utms]
            console.log ["FOMRr", $form]
            return success
        (error) ->
            console.log ["Ocurrio un error", error]
    )


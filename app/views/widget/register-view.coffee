template = require 'views/templates/widget/register'
View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'
vendor = require 'lib/vendor'
zipCode = require 'lib/zipCode'

module.exports = class RegisterView extends View
  autoRender: yes
  container: '#register-modal-body'
  template: template

  render: ->
    super

  initialize: ->
    super
    @delegate "click", "#registerStep1", @registerStep1
    @delegate "click", "#registerStep2", @registerStep2
    @delegate 'click', '#register-by-facebook', @doRegisterWithFacebook
    @delegate 'click', "#withAccountLink", @withAccountLink

    @subscribeEvent "showCompletaRegister", @showCompletaRegister
    @subscribeEvent 'showRegisterByReferredCode', @showRegisterByReferredCode
    @delegate 'keyup', '.zipCode', @findZipcode

  attach: ->
    super
    vendor.customSelect( @$('.select') )
    vendor.customRadio( @$(".divGender") )

    @$el.find("form#complete-register-form").validate
      ignore: ''
      rules:
        name:
          minlength: 2
        lastName:
          minlength: 2
        zipCode:
          minlength: 5
          digits: true
        phone:
          minlength: 7
          digits: true
        birthdate:
          dateISO: true
          validDate: true


    $select = Backbone.$('.select')
    $zipCode = Backbone.$('.zipCode')
    $zipCodeExtra = Backbone.$('.zipCodeInfoExtra')
    zipCode(Backbone.$).find $zipCode.val(), $select, $zipCodeExtra.val()
    unless $zipCode.val().length < 5
      vendor.customSelect($select)

  showCompletaRegister: (algo)->
    console.log("En completa registro")
    @publishEvent 'showRegister'
    @$el.find("#winbits-register-form").hide()
    @$el.find("#complete-register-layer").show()



  registerStep1: (e)->
    e.preventDefault()
    console.log "RegisterView#registerStep1"
    $form =  @$el.find("#winbits-register-form")
    that = @
    formData = verticalId: config.verticalId
    formData = util.serializeForm($form, formData)
    console.log ["Register Data", formData]
    Backbone.$.ajax config.apiUrl + "/affiliation/register.json",
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
        w$('.modal').modal 'hide'
        that.publishEvent "showConfirmation"


      error: (xhr, textStatus, errorThrown) ->
        console.log xhr
        error = JSON.parse(xhr.responseText)
        that.renderRegisterFormErrors $form, error

      complete: ->
        console.log "Request Completed!"

  registerStep2: (e)->
    e.preventDefault()
    that = @
    $form =  @$el.find("#complete-register-form")
    console.log ['form', $form]
    console.log ['form valid', $form.valid()]

    day = $form.find(".day-input").val()
    month = $form.find(".month-input").val()
    year = $form.find(".year-input").val()
    birthday = ''
    if day or month or year
      birthday = ((if year > 13 then "19" else "20") + year + "-" + month + "-" + day)
      $form.find("[name=birthdate]").val(birthday)
      console.log ['birthdate 1', $form.find("[name=birthdate]").val()]

    gender = $form.find("[name=gender][checked]").val()
    gender = if gender is 'H' then 'male' else 'female'
    location = $form.find("[name=zipCodeInfoExtra]").val()

    if $form.valid()
      formData = verticalId: config.verticalId
      formData = util.serializeForm($form, formData)
      formData.gender = gender
      formData.location = location

      Backbone.$.ajax config.apiUrl + "/affiliation/profile.json",
        type: "PUT"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(formData)
        context: $form
        beforeSend: ->
          util.validateForm this

        headers:
          "Accept-Language": "es"
          "WB-Api-Token": util.getCookie(config.apiTokenName)

        success: (data) ->
          console.log ["Profile updated", data.response]
          Backbone.$('.modal').modal 'hide'
          that.publishEvent "setProfile", data.response

        error: (xhr, textStatus, errorThrown) ->
          error = JSON.parse(xhr.responseText)
          alert "Error while updating profile"

        complete: ->
          console.log "Request Completed!"

  renderRegisterFormErrors: ($form, error) ->
    code = error.code or error.meta.code
    if code is "AFER001"
      message = error.message or error.meta.message
      $form.find(".errors").html "<p>" + message + "</p>"

  showRegisterByReferredCode: (e) ->
    params = window.location.search.substr(1).split('&')
    paramsMap = params.reduce(_reduce = (a, b) ->
      b = b.split('=')
      a[b[0]] = b[1]
      a
    , {})
    if paramsMap.a is "register"
      @publishEvent 'showRegister'
      @publishEvent "setRegisterFb", {referredCode: paramsMap.rc}


  doRegisterWithFacebook: (e) ->
    e.preventDefault()
    $ = Backbone.$
    that = @
    referredBy = $("#referredById")[0].value
    popup = window.open(config.apiUrl + "/affiliation/facebook-login/connect?verticalId=" + config.verticalId +
        "&referredBy=" + referredBy,
        "facebook", "menubar=0,resizable=0,width=800,height=500")
    popup.postMessage
    popup.focus()
    timer = setInterval(->
      if popup.closed
        clearInterval timer
        $(".modal").modal('hide')
        that.publishEvent 'expressLogin'
    , 1000)

  withAccountLink: (e) ->
    @publishEvent 'showLogin', e

  findZipcode: (event)->
    event.preventDefault()
    console.log "find zipCode"
    $currentTarget = @$(event.currentTarget)
    $slt = $currentTarget.parent().find(".select")
    zipCode(Backbone.$).find $currentTarget.val(), $slt
template = require 'views/templates/widget/register'
View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'

module.exports = class RegisterView extends View
  autoRender: yes
  container: '#register-modal-body'
  template: template

  render: ->
    console.log "(>|<)"
    super

  initialize: ->
    super
    @delegate "click", "#registerStep1", @registerStep1
    @delegate "click", "#registerStep2", @registerStep2

    @subscribeEvent "showCompletaRegister", @showCompletaRegister

  attach: ()->
    super
    @$el.find("#winbits-register-form").valid()

  showCompletaRegister: (algo)->
    console.log("En completa registro")
    @publishEvent 'showRegister'
    @$el.find("#winbits-register-form").hide()
    @$el.find("#complete-register-layer").show()



  registerStep1: (e)->
    e.preventDefault()
    console.log "RegisterView#registerStep1"
    $form =  @$el.find("#winbits-register-form")
    console.log $form
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
        $('.modal').modal 'hide'
        that.publishEvent "showConfirmation"


      error: (xhr, textStatus, errorThrown) ->
        console.log xhr
        error = JSON.parse(xhr.responseText)
        that.renderRegisterFormErrors $form, error

      complete: ->
        console.log "Request Completed!"

  registerStep2: (e)->
    e.preventDefault()

    $form =  @$el.find("#complete-register-form")
    $form.validate rules:
      birthdate:
        dateISO: true

    day = $form.find("#day-input").val()
    month = $form.find("#month-input").val()
    year = $form.find("#year-input").val()
    $form.find("[name=birthdate]").val ((if year > 13 then "19" else "20")) + year + "-" + month + "-" + day  if day or month or year
    formData = verticalId: config.verticalId
    formData = util.serializeForm($form, formData)
    delete formData.location  if formData.location is $form.find("[name=location]").attr("placeholder")
    formData.gender = (if formData.gender is "H" then "male" else "female")  if formData.gender
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
        @publishEvent "setProfile", data.response

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


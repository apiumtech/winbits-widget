template = require 'views/templates/widget/profile'
View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'
token = require 'lib/token'
mediator = require 'chaplin/mediator'

module.exports = class ProfileView extends View
  autoRender: yes
  #className: 'home-page'
  container: '#headerProfile'
  template: template

  render: ->
    console.log "(:})"
    super


  initialize: ->
    super
    @delegate 'click', '#updateBtnProfile', @saveProfile
    @delegate 'click', '#editBtnProfile', @editProfile

  editProfile: (e)->
    console.log "---->"
    @$el.find(".miPerfil").slideUp()
    @$el.find(".editMiPerfil").slideDown()

  saveProfile: (e)->
    e.preventDefault()
    e.stopPropagation()
    console.log "ProfileView#saveProfile"
    $form = @$el.find("#update-profile-form")
    day = $form.find("[name=day-input]").val()
    month = $form.find("[name=month-input]").val()
    year = $form.find("[name=year-input]").val()
    console.log day
    console.log month
    console.log year
    if day or month or year
      $form.find("[name=birthdate]").val ((if year > 13 then "19" else "20")) + year + "-" + month + "-" + day

    console.log $form.find("[name=birthdate]")
    console.log $form.valid()
    that = this
    if $form.valid()
      data: JSON.stringify(formData)
      formData = { verticalId: config.verticalId }
      formData = util.serializeForm($form, formData)
      console.log formData
      @model.set formData
      @model.sync 'update', @model,
        error: ->
          console.log "error",
        headers:{ 'Accept-Language': 'es', 'WB-Api-Token': util.getCookie(config.apiTokenName) }
        success: ->
          console.log "success"
          #that.$el.find(".myPerfil").slideDown()
          #that.$el.find(".editMiPerfil").slideUp()
        #emulateHTTP: true

    console.log JSON.stringify(@model)

  attach: ->
    super
    $form = @$el.find("#update-profile-form")
    $form.validate rules:
      birthdate:
        dateISO: true

    util.openFolder Backbone.$,
      obj: ".myProfile .miPerfil"
      trigger: ".myProfile .miPerfil .changePassBtn"
      objetivo: ".myProfile .changePassDiv"

    util.openFolder Backbone.$,
      obj: ".myProfile .changePassDiv"
      trigger: ".myProfile .changePassDiv"
      objetivo: ".myProfile .miPerfil"



template = require 'views/templates/widget/profile'
View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'
zipCode = require 'lib/zipCode'
token = require 'lib/token'
mediator = require 'chaplin/mediator'

module.exports = class ProfileView extends View
  autoRender: yes
  #className: 'home-page'
  container: '#headerProfile'
  template: template

  render: ->
    super


  initialize: ->
    super
    @delegate 'click', '#updateBtnProfile', @saveProfile
    @delegate 'click', '#editBtnProfile', @editProfile
    @delegate 'keyup', '.zipCode', @findZipcode
    @delegate 'click', '#attachTwitterAccountOff', @viewAttachTwitterAccount
    @delegate 'click', '#attachFacebookAccountOff', @viewAttachFacebookAccount
    @delegate 'click', '#attachTwitterAccountOn', @viewDetachTwitterAccount
    @delegate 'click', '#attachFacebookAccountOn', @viewDetachFacebookAccount

    @subscribeEvent 'updateSocialAccountsStatus', @updateSocialAccountsStatus

  editProfile: (e)->
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


  attach: ->
    super
    $form = @$el.find("#update-profile-form")
    $form.validate rules:
      birthdate:
        dateISO: true

    util.openFolder
      obj: ".myProfile .miPerfil"
      trigger: ".myProfile .miPerfil .changePassBtn"
      objetivo: ".myProfile .changePassDiv"

    util.openFolder
      obj: ".myProfile .changePassDiv"
      trigger: ".myProfile .changePassDiv"
      objetivo: ".myProfile .miPerfil"

    util.customSelect(@$('.select'))
    util.customRadio(@$(".divGender"))

    $select = @$('.select')
    $zipCode = @$('.zipCode')
    $zipCodeExtra = @$('.zipCodeInfoExtra')
    zipCode(Backbone.$).find $zipCode.val(), $select, $zipCodeExtra.val()
    unless $zipCode.val().length < 5
      util.customSelect($select)


  findZipcode: (event)->
    event.preventDefault()
    console.log "find zipCode"
    currentTarget = @$(event.currentTarget)
    $slt = @$("#zipCodeInfo")
    zipCode(Backbone.$).find currentTarget.val(), $slt

  viewAttachTwitterAccount: (e)->
    that = @
    console.log "attach-twitter-account"
    maxHeight = Backbone.$(window).height() - 200
    @$("#attach-twitter-account-modal .modal-body").css("max-height", maxHeight)
    @$("#attach-twitter-account-modal").modal( 'show' ).css {
      'background-color': 'transparent',
      float: 'left',
      width: '330px',
      'margin-left': -> -( Backbone.$( this ).width() / 2 )
      top: '50%',
      'max-height': maxHeight,
      'margin-top': -> -(  Backbone.$( this ).height() / 2 )
    }

    popup = window.open("", "twitter", "menubar=0,resizable=0,width=800,height=500")
    popup.postMessage

    Backbone.$.ajax config.apiUrl + "/affiliation/connect/twitter",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: {}
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.getCookie(config.apiTokenName)

      success: (data) ->
        popup.window.location.href = data.response.socialUrl
        popup.focus()
        timer = setInterval(->
            if popup.closed
              clearInterval timer
              Backbone.$(".modal").modal('hide')
              that.publishEvent 'updateSocialAccountsStatus'
        , 1000)

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert error.message

      complete: ->
        console.log "Request Completed!"


  viewAttachFacebookAccount: (e)->
    that = @
    console.log "attach-facebook-account"
    maxHeight = Backbone.$(window).height() - 200
    @$("#attach-facebook-account-modal .modal-body").css("max-height", maxHeight)
    @$("#attach-facebook-account-modal").modal( 'show' ).css {
      'background-color': 'transparent',
      float: 'left',
      width: '330px',
      'margin-left': -> -( Backbone.$( this ).width() / 2 )
      top: '50%',
      'max-height': maxHeight,
      'margin-top': -> -(  Backbone.$( this ).height() / 2 )
    }

    popup = window.open("", "facebook", "menubar=0,resizable=0,width=800,height=500")
    popup.postMessage

    Backbone.$.ajax config.apiUrl + "/affiliation/connect/facebook",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: {}
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.getCookie(config.apiTokenName)

      success: (data) ->
        popup.window.location.href = data.response.socialUrl
        popup.focus()
        timer = setInterval(->
          if popup.closed
            clearInterval timer
            Backbone.$(".modal").modal('hide')
            that.publishEvent 'updateSocialAccountsStatus'
        , 1000)

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert error.message

      complete: ->
        console.log "Request Completed!"


  updateSocialAccountsStatus : () ->
    that = @
    console.log "update social accounts"
    Backbone.$.ajax config.apiUrl + "/affiliation/social-accounts.json",
      type: "GET"
      contentType: "application/json"
      dataType: "json"
      xhrFields:
        withCredentials: true

      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.getCookie(config.apiTokenName)

      success: (data) ->
        console.log "logout.json Success!"
        socialAccounts = data.response.socialAccounts
        facebook = (item for item in socialAccounts when item.providerId is "facebook"  and item.available)
        twitter = (item for item in socialAccounts when item.providerId is "twitter"  and item.available)
        facebookFlag = if facebook != null && facebook.length > 0  then "On" else "Off"
        twitterFlag = if twitter != null && twitter.length > 0 then "On" else "Off"
        that.publishEvent 'setProfile', {twitter: twitterFlag, facebook: facebookFlag}

      error: (xhr, textStatus, errorThrown) ->
        console.log "accounts.json Error!"
        error = JSON.parse(xhr.responseText)
        alert error.meta.message

      complete: ->
        console.log "accounts.json Completed!"

  viewDetachFacebookAccount: (e) ->
    that = @
    console.log "detach facebook account"
    Backbone.$.ajax config.apiUrl + "/affiliation/social-account/facebook.json",
      type: "DELETE"
      contentType: "application/json"
      dataType: "json"
      xhrFields:
        withCredentials: true

      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.getCookie(config.apiTokenName)

      success: (data) ->
        that.publishEvent 'updateSocialAccountsStatus'

      error: (xhr, textStatus, errorThrown) ->
        console.log "deleteAccount.json Error!"
        error = JSON.parse(xhr.responseText)
        alert error.meta.message

      complete: ->
        console.log "deleteAccount.json Completed!"

  viewDetachTwitterAccount: (e) ->
    that = @
    console.log "detach twitter account"
    Backbone.$.ajax config.apiUrl + "/affiliation/social-account/twitter.json",
      type: "DELETE"
      contentType: "application/json"
      dataType: "json"
      data: {id: 'twitter'}
      xhrFields:
        withCredentials: true

      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.getCookie(config.apiTokenName)

      success: (data) ->
        console.log "deleteAccount.json Success!"
        that.publishEvent 'updateSocialAccountsStatus'

      error: (xhr, textStatus, errorThrown) ->
        console.log "deleteAccount.json Error!"
        error = JSON.parse(xhr.responseText)
        alert error.meta.message

      complete: ->
        console.log "deleteAccount.json Completed!"

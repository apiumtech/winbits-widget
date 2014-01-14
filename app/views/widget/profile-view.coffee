template = require 'views/templates/widget/profile'
View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'
zipCode = require 'lib/zipCode'
token = require 'lib/token'
mediator = require 'chaplin/mediator'
vendor = require 'lib/vendor'

module.exports = class ProfileView extends View
  autoRender: yes
  #className: 'home-page'
  container: '#headerProfile'
  template: template

  initialize: ->
    super
    @delegate 'click', '#updateBtnProfile', @saveProfile
    @delegate 'click', '#editBtnProfile', @editProfile
    @delegate 'click', '.linkBack', @cancelEditing
    @delegate 'click', '#attachTwitterAccountOff', @viewAttachTwitterAccount
    @delegate 'click', '#attachFacebookAccountOff', @viewAttachFacebookAccount
    @delegate 'click', '#attachTwitterAccountOn', @viewDetachTwitterAccount
    @delegate 'click', '#attachFacebookAccountOn', @viewDetachFacebookAccount
    @delegate 'click', '#wbi-change-password-link', @changePassword
    @delegate 'click', '#wbi-show-cards-manager-link', @showCardsManager
    @delegate 'submit', '#wbi-change-password-form', @requestPasswordChange
    @delegate 'click', '#wbi-profile-email', @editProfile
    @delegate 'textchange', '.zipCode', @findZipcode
    @delegate 'change', 'select.zipCodeInfo', @changeZipCodeInfo

    @subscribeEvent 'updateSocialAccountsStatus', @updateSocialAccountsStatus
    @subscribeEvent 'profileUpdated', @onProfileUpdated
    @subscribeEvent 'loggedOut', @resetView

  resetView: ->
    @model.clear()
    @render()

  editProfile: (e)->
    e.preventDefault()
    @$el.find(".miPerfil").slideUp()
    @$el.find(".editMiPerfil").slideDown()

  saveProfile: (e)->
    e.preventDefault()
    e.stopPropagation()
    console.log "ProfileView#saveProfile"
    $form = @$el.find("#wbi-update-profile-form")

    birthday = util.getBirthday($form)
    $form.find("[name=birthdate]").val(birthday)
    gender = util.getGender($form)

    if $form.valid()
      formData = util.serializeForm($form)
      if formData.zipCodeInfo and formData.zipCodeInfo > 0
        formData.zipCodeInfo  = {"id": formData.zipCodeInfo}
      formData.gender = gender
      button = @$el.find('#updateBtnProfile').prop 'disabled', true
      Backbone.$.ajax @model.url,
        type: "PUT"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(formData)
        context: {view: @, $saveButton: button}
        headers:{ 'Accept-Language': 'es', 'WB-Api-Token': util.retrieveKey(config.apiTokenName) }
        error: ->
          console.log "error"

        success: (data) ->
          @view.onProfileUpdated data.response

        complete: ->
          @$saveButton.prop 'disabled', false


  attach: ->
    super
    @$el.find("#wbi-update-profile-form").validate
      ignore: ""
      errorPlacement: ($error, $element) ->
        if $element.attr("name") in ['zipCodeInfo']
          $error.appendTo $element.parent()
        else
          $error.insertAfter $element
      rules:
        name:
          required: true
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
        zipCodeInfo:
          required: (e) ->
            $form = Backbone.$(e).closest 'form'
            $form.find('[name=location]').is(':hidden')
        location:
          required: '[name=location]:visible'
          minlength: 2

    @$el.find('form#wbi-change-password-form').validate rules:
      password:
        required: true
        minlength: 5
      newPassword:
        required: true
        minlength: 5
      passwordConfirm:
        required: true
        minlength: 5
        equalTo: '[name=newPassword]'

    vendor.customSelect(@$('.select'))
    vendor.customRadio(@$(".divGender"))

    $select = @$('.select')
    $zipCode = @$('.zipCode')
    $zipCodeExtra = @$('.zipCodeInfoExtra')
    zipCode(Backbone.$).find $zipCode.val(), $select, $zipCodeExtra.val()
    unless $zipCode.val().length < 5
      vendor.customSelect($select)

    @$('input[name=gender]').removeAttr('checked').next().removeClass('spanSelected')
    gender = @model.get 'gender'
    if gender
      @$('input.' + gender).attr('checked', 'checked').next().addClass('spanSelected')

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
        "WB-Api-Token":  util.retrieveKey(config.apiTokenName)

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
        util.showAjaxError(xhr.responseText)

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
        "WB-Api-Token":  util.retrieveKey(config.apiTokenName)

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
        util.showAjaxError(xhr.responseText)

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
        "WB-Api-Token":  util.retrieveKey(config.apiTokenName)

      success: (data) ->
        console.log "accounts.json Success!"
        socialAccounts = data.response.socialAccounts
        facebook = (item for item in socialAccounts when item.providerId is "facebook"  and item.available)
        twitter = (item for item in socialAccounts when item.providerId is "twitter"  and item.available)
        facebookFlag = if facebook != null && facebook.length > 0  then "On" else "Off"
        twitterFlag = if twitter != null && twitter.length > 0 then "On" else "Off"
        that.publishEvent 'setProfile', {twitter: twitterFlag, facebook: facebookFlag}
        mediator.profile.socialAccounts = socialAccounts
        mediator.global.profile.socialAccounts = socialAccounts

      error: (xhr, textStatus, errorThrown) ->
        console.log "accounts.json Error!"
        util.showAjaxError(xhr.responseText)

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
        "WB-Api-Token":  util.retrieveKey(config.apiTokenName)

      success: (data) ->
        that.publishEvent 'updateSocialAccountsStatus'

      error: (xhr, textStatus, errorThrown) ->
        console.log "deleteAccount.json Error!"
        util.showAjaxError(xhr.responseText)

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
        "WB-Api-Token":  util.retrieveKey(config.apiTokenName)

      success: (data) ->
        console.log "deleteAccount.json Success!"
        that.publishEvent 'updateSocialAccountsStatus'

      error: (xhr, textStatus, errorThrown) ->
        console.log "deleteAccount.json Error!"
        util.showAjaxError(xhr.responseText)

      complete: ->
        console.log "deleteAccount.json Completed!"

  cancelEditing: (e) ->
    $editProfileContainer = @$el.find(".editMiPerfil")
    $editProfileContainer.find('form').first().validate().resetForm()
    $editProfileContainer.slideUp()
    $changePasswordContainer = @$el.find(".changePassDiv")
    $changePasswordContainer.find('form').first().validate().resetForm()
    $changePasswordContainer.slideUp()
    @$el.find(".miPerfil").slideDown()
#    util.resetLocationSelect($editProfileForm.find("#wbi-profile-zip-code-info"))

  changePassword: (e) ->
    e.preventDefault()
    @$el.find(".miPerfil").slideUp()
    @$el.find(".changePassDiv").slideDown()

  requestPasswordChange: (e) ->
    e.preventDefault()
    $ = Backbone.$
    $form = $(e.currentTarget)
    formData = util.serializeForm($form)
    console.log "detach twitter account"
    $.ajax config.apiUrl + "/affiliation/change-password.json",
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      context: {$form: $form, that: @}
      beforeSend: ->
        this.$form.valid()
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.retrieveKey(config.apiTokenName)

      success: (data) ->
        console.log "deleteAccount.json Success!"
        this.that.cancelEditing()

      error: (xhr, textStatus, errorThrown) ->
        console.log "deleteAccount.json Error!"
        util.showAjaxError(xhr.responseText)

      complete: ->
        console.log "deleteAccount.json Completed!"

  showCardsManager: (e) ->
    $ = Backbone.$
    $main = $('main').first()
    $('div.dropMenu').slideUp()
    $cardsManagerContainer = $main.find('#wbi-cards-manager')
    if $cardsManagerContainer.is(':hidden')
      $main.children().hide()
      $cardsManagerContainer.parents().show()
      $cardsManagerContainer.show()
      @publishEvent 'showCardsManager'

  findZipcode: (event)->
    event.preventDefault()
    console.log "find zipCode"
    $currentTarget = @$(event.currentTarget)
    $slt = $currentTarget.parent().find(".select")
    zipCode(Backbone.$).find $currentTarget.val(), $slt

  changeZipCodeInfo: (e) ->
    $ = Backbone.$
    $select = $(e.currentTarget)
    zipCodeInfoId = $select.val()
    $form = $select.closest('form')
    $fields = $form.find('[name=location], [name=county], [name=state]')
    if !zipCodeInfoId
      $fields.show().val('').attr('readonly', '').filter('[name=location]').hide()
    else if zipCodeInfoId is '-1'
      $fields.show().removeAttr('readonly')
    else
      $fields.show().attr('readonly', '').filter('[name=location]').hide()
    $option = $select.children('[value=' + zipCodeInfoId + ']')
    zipCodeInfo = $option.data 'zip-code-info'
    if zipCodeInfo
      $form.find('input.zipCode').val zipCodeInfo.zipCode
      $fields.filter('[name=county]').val zipCodeInfo.county
      $fields.filter('[name=state]').val zipCodeInfo.state

  onProfileUpdated: (profile) ->
    @publishEvent "setProfile", profile.profile
    @publishEvent 'setBitsBalance', profile.bitsBalance
    console.log profile.cashback
    if (profile.cashback > 0 )
      @publishEvent 'completeRegister', profile.cashback
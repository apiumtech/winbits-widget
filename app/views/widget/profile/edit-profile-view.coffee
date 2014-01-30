View = require 'views/base/view'
template = require 'views/templates/widget/profile/edit-profile'
config = require 'config'
util = require 'lib/util'
zipCode = require 'lib/zipCode'
token = require 'lib/token'
mediator = require 'chaplin/mediator'
vendor = require 'lib/vendor'


module.exports = class EditProfileView extends View
  autoRender: yes
  #className: 'home-page'
  container: '#wbi-edit-profile-view'
  template: template

  initialize: ->
    super
    @subscribeEvent 'savePersonalInfo', @savePersonalInfo
    @subscribeEvent 'renderEditProfile', @render
    @subscribeEvent 'editProfileInfo', @showEditProfile


  render: ->
    super

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
          zipCodeDoesNotExist: true
          required: (e) ->
            $zipCodeInfo = Winbits.$(e)
            $form = $zipCodeInfo.closest 'form'
            if $form.find('[name=location]').is(':hidden')
              $zipCode = $form.find('[name=zipCode]')
              not $zipCode.val() or (not $zipCodeInfo.val() and $zipCodeInfo.children().length > 1)
            else
              false
        location:
          required: '[name=location]:visible'
          minlength: 2
    vendor.customSelect(@$('.select'))
    vendor.customRadio(@$(".divGender"))

    $select = @$('.select')
    $zipCode = @$('.zipCode')
    zipCodeInfoId = undefined

    if @model.attributes.zipCodeInfo?
      zipCodeInfoId= @model.attributes.zipCodeInfo.id
    else
      if @model.attributes.location
       zipCodeInfoId = -1
      else
       zipCodeInfoId = undefined

    zipCode(Winbits.$).find $zipCode.val(), $select, zipCodeInfoId

    unless $zipCode.val().length < 5
      vendor.customSelect($select)

    @$('input[name=gender]').removeAttr('checked').next().removeClass('spanSelected')
    gender = @model.get 'gender'
    if gender
      @$('input.' + gender).attr('checked', 'checked').next().addClass('spanSelected')

  showEditProfile:(data) ->
    @publishEvent 'setPersonalInfo', data
    @$el.find(".miPerfil").slideUp()
    @$el.find(".editMiPerfil").slideDown()

  savePersonalInfo: ->
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
      util.ajaxRequest( @model.url,
        type: "PUT"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(formData)
        context: {view: @, $saveButton: button}
        headers:{ 'Accept-Language': 'es', 'WB-Api-Token': util.retrieveKey(config.apiTokenName) }
        error: ->
          console.log "error"
        success: (data) ->
          @view.publishEvent 'profileUpdated', data.response
          $editProfileContainer =  @view.$el.find(".editMiPerfil")
          $editProfileContainer.slideUp  ->
            util.justResetForm $editProfileContainer.find('form')
          @view.$el.find(".miPerfil").slideDown()
        complete: ->
          button.prop 'disabled', false
      )

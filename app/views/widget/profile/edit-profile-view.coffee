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
    $zipCodeExtra = @$('.zipCodeInfoExtra')
    zipCode(Winbits.$).find $zipCode.val(), $select, $zipCodeExtra.val()
    unless $zipCode.val().length < 5
      vendor.customSelect($select)

    @$('input[name=gender]').removeAttr('checked').next().removeClass('spanSelected')
    gender = @model.get 'gender'
    if gender
      @$('input.' + gender).attr('checked', 'checked').next().addClass('spanSelected')

  showEditProfile:(data) ->
    console.log ['Data-->', data]
    @publishEvent 'setPersonalInfo', data
    @$el.find(".miPerfil").slideUp()
    @$el.find(".editMiPerfil").slideDown()

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
    @delegate 'click', ".wb-close-complete-profile-layer-link", @closeCompleteRegisterModal
    @delegate 'textchange', '.zipCode', @findZipcode
    @delegate 'change', 'select.zipCodeInfo', @changeZipCodeInfo

    @subscribeEvent "showCompletaRegister", @showCompletaRegister
    @subscribeEvent 'showRegisterByReferredCode', @showRegisterByReferredCode

  attach: ->
    super
    vendor.customSelect( @$('.select') )
    vendor.customRadio( @$(".divGender") )

    @$el.find('#winbits-register-form').validate
      rules:
        email:
          required: true
          email: true
        password:
          required: true
          minlength: 5
        passwordConfirm:
          equalTo: "#password"

    @$el.find("form#complete-register-form").validate
      ignore: ''
      errorPlacement: ($error, $element) ->
        if $element.attr("name") in ['zipCodeInfo']
          $error.appendTo $element.parent()
        else
          $error.insertAfter $element
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
        zipCodeInfo:
          required: (e) ->
            $form = Winbits.$(e).closest 'form'
            $form.find('[name=location]').is(':hidden')
        location:
          required: '[name=location]:visible'
          minlength: 2

    $select = @$el.find('.select')
    $zipCode = @$el.find('.zipCode')
    $zipCodeExtra = @$el.find('.zipCodeInfoExtra')
    zipCode(Winbits.$).find $zipCode.val(), $select, $zipCodeExtra.val()
    unless $zipCode.val().length < 5
      vendor.customSelect($select)

  showCompletaRegister: () ->
    console.log("En completa registro")
    Winbits.$('a#wbi-dummy-link').get(0).click()
    @publishEvent 'showRegister'
    @$el.find("#winbits-register-form").hide()
    @$el.find("#complete-register-layer").show()

  registerStep1: (e)->
    e.preventDefault()
    console.log "RegisterView#registerStep1"
    $form =  @$el.find("#winbits-register-form")
    formData = verticalId: config.verticalId
    formData = util.serializeForm($form, formData)
    console.log ["Register Data", formData]

    if $form.valid()
      submitButton = @$(e.currentTarget).prop('disabled', true)
      util.ajaxRequest(config.apiUrl + "/users/register.json",
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
          console.log "Request Success!"
          console.log ["data", data]
          Winbits.$('.modal').modal 'hide'
          @view.publishEvent "showConfirmation"
        error: (xhr) ->
          console.log 'Error response '
          console.log xhr
          error = JSON.parse(xhr.responseText)
          @view.renderRegisterFormErrors $form, error
        complete: ->
          console.log "Request Completed!"
          @$submitButton.prop('disabled', false)
      )

  registerStep2: (e)->
    e.preventDefault()
    $form =  @$el.find("#complete-register-form")

    birthday = util.getBirthday($form)
    $form.find("[name=birthdate]").val(birthday)
    gender = util.getGender($form)

    if $form.valid()
      formData = util.serializeForm($form)
      if formData.zipCodeInfo and formData.zipCodeInfo > 0
        formData.zipCodeInfo  = {id: formData.zipCodeInfo}
      else
        delete formData.zipCodeInfo
      formData.gender = gender

      $saveButton = Winbits.$(e.currentTarget).val('Guardando...').prop('disabled', true)
      util.ajaxRequest(config.apiUrl + "/users/profile.json",
        type: "PUT"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(formData)
        context: { view: @, $form: $form, $saveButton: $saveButton }
        beforeSend: ->
          util.validateForm @$form
        headers:
          "Accept-Language": "es"
          "WB-Api-Token": util.retrieveKey(config.apiTokenName)
        success: (data) ->
          @view.publishEvent "profileUpdated", data.response
          Winbits.$('#register-modal').modal 'hide'
        error:  ->
          util.showError("Error while updating profile")
        complete: ->
          @$saveButton.val('Guardar').prop('disabled', false)
      )

  renderRegisterFormErrors: ($form, error) ->
    code = error.code or error.meta.code
    if code is "AFER001"
      @publishEvent ('alreadyexistuser')
    if code is "AFER026"
      @publishEvent ('alreadyexistusernotconfirmed'), error.response.resendConfirmUrl

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
    $ = Winbits.$
    that = @
    fbButton = @$(e.currentTarget).prop('disabled', true)
    referredBy = $("#referredById")[0].value
    popup = window.open(config.apiUrl + "/users/facebook-login/connect?verticalId=" + config.verticalId +
        "&referredBy=" + referredBy,
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

  withAccountLink: (e) ->
    @publishEvent 'showLogin', e

  closeCompleteRegisterModal: (e) ->
    e.preventDefault()
    Winbits.$(e.currentTarget).closest('#register-modal').modal('hide')

  findZipcode: (event)->
    event.preventDefault()
    console.log "find zipCode"
    $currentTarget = @$(event.currentTarget)
    $slt = $currentTarget.parent().find(".select")
    zipCode(Winbits.$).find $currentTarget.val(), $slt

  changeZipCodeInfo: (e) ->
    $ = Winbits.$
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
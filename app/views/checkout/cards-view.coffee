View = require 'views/base/view'
template = require 'views/templates/checkout/cards'
util = require 'lib/util'
vendor = require 'lib/vendor'
config = require 'config'
mediator = require 'chaplin/mediator'

# Site view is a top-level view which is bound to body.
module.exports = class CardsView extends View
  container: '#wbi-cards'
  containerMethod: 'prepend'
  autoRender: yes
  template: template

  initialize: ->
    super
    console.log "CardsView#initialize"
    @delegate "click" , "#wbi-add-new-card-link", @showNewAddressForm
    @delegate "click" , "#wbi-cancel-card-form-btn", @cancelSaveUpdateCard
#    @delegate "click" , "#btnSubmit", @addressSubmit
#    @delegate "click" , ".btnUpdate", @addressUpdate
#    @delegate "click" , ".edit-address", @editAddress
#    @delegate "click" , ".delete-address", @deleteAddress
#    @delegate "click" , "#btnContinuar", @addressContinuar
#    @delegate "click" , ".shippingItem", @selectShipping
#    @delegate 'keyup', '.zipCode', @findZipcode

  attach: ->
    super
    console.log "CardsView#attach"
    @$el.find("#wbi-card-form").validate
      groups:
        cardExpiration: 'expirationMonth expirationYear'
      errorPlacement: ($error, $element) ->
        if $element.attr("name") is "expirationMonth" or $element.attr("name") is "expirationYear"
          $error.appendTo $element.parent()
        else
          $error.insertAfter $element
      rules:
        firstName:
          required: true
          minlength: 2
        lastName:
          required: true
          minlength: 2
        accountNumber:
          required: true
          creditcard: true
        expirationMonth:
          required: true
          minlength: 2
          digits: true
          range: [1, 12]
        expirationYear:
          required: true
          minlength: 2
          digits: true
        cvNumber:
          required: true
          digits: true
          minlength: 3
        street1:
          required: true
          minlength: 2
        number:
          required: true
        postalCode:
          required: true
          minlength: 5
          digits: true
        phone:
          required: true
          minlength: 7
          digits: true
        state:
          required: true
          minlength: 2
        colony:
          required: true
          minlength: 2
        municipality:
          required: true
          minlength: 2
        city:
          required: true
          minlength: 2

  showNewAddressForm: (e) ->
    e.preventDefault()
    $form = @$el.find('form#wbi-card-form')
    $form.validate().resetForm()
    @$el.find('#wbi-cards-list-holder').hide()
    $form.find('#wbi-update-card-form-btn').hide()
    $form.find('#wbi-save-card-form-btn').show()
    $form.parent().show()

  cancelSaveUpdateCard: (e) ->
    e.preventDefault()
    $form = @$el.find('form#wbi-card-form')
    $form.parent().hide()
    @$el.find('#wbi-cards-list-holder').show()

  deleteAddress: (e)->
    console.log "deleting address"
    $currentTarget = @$(e.currentTarget)
    that = @
    id =  $currentTarget.attr("id").split("-")[1]
    @model.sync 'delete', @model,
      url: config.apiUrl + "/affiliation/shipping-addresses/" + id,
      error: ->
        console.log "error",
          headers:{ 'Accept-Language': 'es', 'WB-Api-Token': util.getCookie(config.apiTokenName) }
          success: ->
        console.log "success"
        that.model.actualiza()

  selectShipping: (e)->
    $currentTarget = @$(e.currentTarget)
    console.log $currentTarget.attr("id")
    id =  $currentTarget.attr("id").split("-")[1]
    @$(".shippingItem").removeClass("shippingSelected")
    $currentTarget.addClass("shippingSelected")
    mediator.post_checkout.shippingAddress = id


  addressContinuar: (e)->
    console.log "continuar"
    $addresSelected = @$(".shippingSelected")
    id = $addresSelected.attr("id").split("-")[1]
    if id
      mediator.post_checkout.shippingAddress = id
    if mediator.post_checkout.shippingAddress
      @publishEvent "showStep", ".checkoutPaymentContainer"
      @$("#choosen-address-" + mediator.post_checkout.shippingAddress).show()


  editAddress: (e)->
    e.principal
    $currentTarget = @$(e.currentTarget)
    id =  $currentTarget.attr("id").split("-")[1]
    $editAddress = @$("#shippingEditAddress-" + id)
    @$(".shippingAddresses").hide()
    $editAddress.show()
  newAddress: (e)->
    e.preventDefault()
    @$(".shippingAddresses").hide()
    @$("#shippingNewAddress").show()

  cancelEdit: (e)->
    e.preventDefault()
    @$(".shippingAddresses").show()
    @$(".shippingNewAddress").hide()
    @$(".shippingEditAddress").hide()

  addressSubmit: (e)->
    e.preventDefault()
    console.log "AddressSubmit"
    $form = @$el.find("#shippingNewAddress")
    console.log $form.valid()
    if $form.valid()
      data: JSON.stringify(formData)
      formData = util.serializeForm($form)
      formData.country  = {"id": formData.country}
      formData.zipCodeInfo  = {"id": formData.zipCodeInfoId}
      formData.main = if formData.main then true else false
      console.log formData
      @model.set formData

      that = @
      @model.sync 'create', @model,
        error: ->
          console.log "error",
            headers: { 'Accept-Language': 'es', 'WB-Api-Token': util.getCookie(config.apiTokenName) }
            success: ->
          console.log "success"
          that.model.actualiza()
  #that.$el.find(".myPerfil").slideDown()
  #
  addressUpdate: (e)->
    e.preventDefault()
    console.log "AddressUpdate"
    $currentTarget = @$(e.currentTarget)
    id =  $currentTarget.attr("id").split("-")[1]
    $form = @$el.find("#shippingEditAddress-" + id)
    if $form.valid()
      formData = util.serializeForm($form)
      formData.country  = {"id": formData.country}
      formData.zipCodeInfo  = {"id": formData.zipCodeInfoId}
      if formData.principal
        formData.principal  = true
      else
        formData.principal = false
      formData.contactName = formData.name + " " + formData.lastname
      console.log formData
      @model.set formData
      that = @
      @model.sync 'update', @model,
        url: config.apiUrl + "/affiliation/shipping-addresses/" + formData.id,
        error: ->
          console.log "error",
            headers:{ 'Accept-Language': 'es', 'WB-Api-Token': util.getCookie(config.apiTokenName) }
            success: ->
          console.log "success"
          that.model.actualiza()

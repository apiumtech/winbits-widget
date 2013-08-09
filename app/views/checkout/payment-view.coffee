View = require 'views/base/view'
template = require 'views/templates/checkout/payment-methods'
util = require 'lib/util'
config = require 'config'
mediator = require 'chaplin/mediator'

# Site view is a top-level view which is bound to body.
module.exports = class PaymentView extends View
  container: '.checkoutPaymentContainer'
  autoRender: yes
  #regions:
  #'#header-container': 'header'
  #'#page-container': 'main'
  template: template

  initialize: ->
    super
    @delegate "click" , ".li-method", @selectMethod
    @delegate "click" , ".submitOrder", @submitOrder
    @delegate "click", ".linkBack", @linkBack
    @delegate "click", ".btnPaymentCancel", @linkBack
    @delegate "click", "#spanCheckboxSaveCard", @selectCheckboxOption
    @delegate "click", "#spanCheckboxAsPrincipal", @selectCheckboxOption
    @delegate "click", ".submitCheckoutPaymentNewCard", @payWithCard

  payWithCard: (e) ->
    e.preventDefault()
    $form = @$el.find("#checkoutPaymentNewCardFormId")
    $currentTarget = @$(e.currentTarget)
    paymentMethod =  $currentTarget.attr("id").split("-")[1]

    if $form.valid()
      console.log ['valid', $form]
      formData = util.serializeForm($form)
      formData.paymentMethod = { "id": paymentMethod }
      formData.order = { "id": mediator.post_checkout.order}
      formData.vertical = { "id": window.verticalId}
      formData.shippingAddress = {"id": mediator.post_checkout.shippingAddress}

      Backbone.$.ajax config.apiUrl + "/orders/payment.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(formData)

        headers:{ 'Accept-Language': 'es', 'WB-Api-Token': window.token }
        success: (data) ->
          console.log ["data", data]

        error: (xhr, textStatus, errorThrown) ->
          console.log xhr
          error = JSON.parse(xhr.responseText)
          #that.renderLoginFormErrors $form, error

        complete: ->
          console.log "Request Completed!"

  selectCheckboxOption: (e)->
    e.preventDefault()
    $currentTarget = @$(e.currentTarget)
    option = $currentTarget.parent().find(".checkbox")
    checkboxStatus = option.prop("checked")
    console.log ['Checkbox status: ' , checkboxStatus]
    if checkboxStatus
      $currentTarget.removeClass "selectCheckbox"
      $currentTarget.addClass "unselectCheckbox"
      option.removeAttr "checked"
    else
      $currentTarget.removeClass "unselectCheckbox"
      $currentTarget.addClass "selectCheckbox"
      option.attr "checked", "checked"




  selectMethod: (e)->
    e.preventDefault()
    $currentTarget = @$(e.currentTarget)
    methodName =  $currentTarget.attr("id").split("-")[1]
    selector = "#method-" + methodName
    console.log ["Selector", selector]
    @$(selector).show()
    @$(".checkoutPaymentCreditcard").hide()

  submitOrder: (e)->
    e.preventDefault()
    console.log "submit order"
    that = @
    $currentTarget = @$(e.currentTarget)
    paymentMethod =  $currentTarget.attr("id").split("-")[1]
    mediator.post_checkout.paymentMethod = paymentMethod

    formData = mediator.post_checkout
    formData.vertical = window.verticalId

    Backbone.$.ajax config.apiUrl + "/orders/payment.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)

      headers:{ 'Accept-Language': 'es', 'WB-Api-Token': window.token }
      success: (data) ->
        console.log ["data", data]
        that.publishEvent "setConfirm", data.response.payments[0]
        that.publishEvent "showStep", ".checkoutSummaryContainer"


      error: (xhr, textStatus, errorThrown) ->
        console.log xhr
        error = JSON.parse(xhr.responseText)
        that.renderLoginFormErrors $form, error

      complete: ->
        console.log "Request Completed!"


  linkBack: (e) ->
    e.preventDefault()
    @$(".checkoutPaymentCreditcard").show()
    @$(".method-payment").hide()


  attach: ->
    super

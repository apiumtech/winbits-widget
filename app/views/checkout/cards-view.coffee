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
    @delegate "click" , "#wbi-add-new-card-link", @showNewCardForm
    @delegate "click" , ".wb-cancel-card-form-btn", @cancelSaveUpdateCard
    @delegate "click" , ".wb-edit-card-link", @showEditCardForm
    @delegate "submit" , "#wbi-new-card-form", @submitNewCardForm
    @delegate "submit" , "#wbi-edit-card-form", @submitEditCardForm
    @delegate "click", ".wb-delete-card-link", @confirmDeleteCard
    @delegate "click", ".wb-card-list-item", @selectCard
    @delegate "keyup", ".wb-card-number-input", @showCardType
    @delegate "blur", ".wb-card-number-input", @showCardType

  attach: ->
    super
    console.log "CardsView#attach"
    @$el.find(".wb-card-form").validate
      groups:
        cardExpiration: 'expirationMonth expirationYear'
      errorPlacement: ($error, $element) ->
        if $element.attr("name") in ["expirationMonth", "expirationYear", 'accountNumber']
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

  showNewCardForm: (e) ->
    e.preventDefault()
    $form = @$el.find('form#wbi-new-card-form')
    $form.validate().resetForm()
    @$el.find('#wbi-cards-list-holder').hide()
    $form.parent().show()

  cancelSaveUpdateCard: (e) ->
    e.preventDefault()
    @showCardsList()

  showCardsList: () ->
    @$el.find('.wb-cards-subview').hide()
    @$el.find('#wbi-cards-list-holder').show()

  showEditCardForm: (e) ->
    e.preventDefault()
    e.stopPropagation()
    $form = @$el.find('form#wbi-edit-card-form')
    cardIndex = @$el.find(e.currentTarget).closest('li').index()
    cardInfo = @model.get('cards')[cardIndex].cardInfo
    $form.data('current-card-data', cardInfo)
    $form.data('current-card-index', cardIndex)
    @fillEditCardForm $form, cardInfo
    @$el.find('#wbi-cards-list-holder').hide()
    $form.parent().show()

  fillEditCardForm: ($form, cardInfo) ->
    $ = Backbone.$
    $form.validate().resetForm()
    formData = $.extend {}, cardInfo.cardData, cardInfo.cardAddress
    if formData.expirationYear and formData.expirationYear.length
      formData.expirationYear = formData.expirationYear.slice(-2)
    $.each formData, (key, value) ->
      $form.find('[name=' + key + ']').val value
    cardType = cardInfo.cardData.cardType.toLowerCase()
    $form.find('span.wb-card-logo').removeAttr('class').attr('class', 'wb-card-logo icon ' + cardType + 'CC')

    cardPrincipal = cardInfo.cardPrincipal
    cardPrincipalCheckbox = $form.find('[name=cardPrincipal]')

    if cardPrincipal? and (cardPrincipal ^ cardPrincipalCheckbox.prop("checked"))
      cardPrincipalCheckbox.trigger('click')


  submitNewCardForm: (e) ->
    e.preventDefault()
    $ = Backbone.$
    $form = $(e.currentTarget)
    newCardData = util.serializeForm($form)
    newCardData.cardPrincipal = newCardData.cardPrincipal is true or newCardData.cardPrincipal is 'on'
    $submitTriggers = $form.find('.wb-submit-trigger').prop('disabled', true)
    util.showAjaxIndicator()
    $.ajax config.apiUrl + "/orders/card-subscription.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      context: { that: @, $form: $form, $submitTriggers: $submitTriggers }
      data: JSON.stringify(paymentInfo: newCardData)
      headers:
        "Accept-Language": "es",
        "WB-Api-Token": util.getCookie(config.apiTokenName)
      beforeSend: ->
        @$form.valid()

      success: (data) ->
        console.log ["Save new card success!", data]
        @that.publishEvent 'showCardsManager'

      error: (xhr) ->
        util.showAjaxError(xhr.responseText)

      complete: ->
        console.log "Request Completed!"
        @$submitTriggers.prop('disabled', false)
        util.hideAjaxIndicator()

  submitEditCardForm: (e) ->
    e.preventDefault()
    $ = Backbone.$
    $form = $(e.currentTarget)
    currentCardData = $form.data('current-card-data')
    updatedCardData = util.serializeForm($form)
    updatedCardData.cardPrincipal = updatedCardData.cardPrincipal is true or updatedCardData.cardPrincipal is 'on'
    $submitTriggers = $form.find('.wb-submit-trigger').prop('disabled', true)
    util.showAjaxIndicator()
    $.ajax config.apiUrl + "/orders/card-subscription/" + currentCardData.subscriptionId + ".json",
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      context: { that: @, $form: $form, $submitTriggers: $submitTriggers }
      data: JSON.stringify(paymentInfo: updatedCardData)
      headers:
        "Accept-Language": "es",
        "WB-Api-Token": util.getCookie(config.apiTokenName)
      beforeSend: ->
        @$form.valid()

      success: (data) ->
        console.log ["Update card success!", data]
        @that.publishEvent 'showCardsManager'
        #cards = @that.model.get 'cards'
        #currentCardIndex = @$form.data('current-card-index')
        #cards.splice(currentCardIndex, 1, cardInfo: data.response)
        #@that.showCardsList()
        #@that.render()

      error: (xhr) ->
        util.showAjaxError(xhr.responseText)

      complete: ->
        console.log "Request Completed!"
        $submitTriggers.prop('disabled', false)
        util.hideAjaxIndicator()

  confirmDeleteCard: (e) ->
    e.preventDefault()
    e.stopPropagation()
    $ = Backbone.$
    cardIndex = @$el.find(e.currentTarget).closest('li').index()
    cardInfo = @model.get('cards')[cardIndex].cardInfo
    answer = confirm '¿En verdad quieres eliminar la tarjeta ' + cardInfo.cardData.accountNumber + '?'
    if answer
      $.ajax config.apiUrl + "/orders/card-subscription/" + cardInfo.subscriptionId + ".json",
        type: "DELETE"
        dataType: "json"
        context: { that: @, cardIndex: cardIndex }
        headers:
          "Accept-Language": "es",
          "WB-Api-Token": util.getCookie(config.apiTokenName)

        success: (data) ->
          console.log ["Delete card success!", data]
          cards = @that.model.get 'cards'
          cards.splice(@cardIndex, 1)
          @that.render()

        error: (xhr) ->
          util.showAjaxError(xhr.responseText)

        complete: ->
          console.log "Request Completed!"

  selectCard: (e) ->
    e.preventDefault()
    $selectedCard = @$el.find(e.currentTarget)
    if not $selectedCard.is('.creditcardSelected')
      $selectedCard.siblings('.creditcardSelected').removeClass('creditcardSelected')
      $selectedCard.addClass('creditcardSelected')
      cardIndex = $selectedCard.index()
      cardInfo = @model.get('cards')[cardIndex].cardInfo
      @publishEvent 'cardSelected', { cardIndex: cardIndex, cardInfo: cardInfo }
      if @model.mainOnClick
        @setMainCard cardInfo

  setMainCard: (cardInfo) ->
    $ = Backbone.$
    util.showAjaxIndicator()
    url = config.apiUrl + "/orders/card-subscription/" + cardInfo.subscriptionId + "/main.json"
    $.ajax url,
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      context: { that: @ }
      headers:
        "Accept-Language": "es",
        "WB-Api-Token": util.getCookie(config.apiTokenName)

      success: (data) ->
        console.log ["Update main card success!", data]
        @that.publishEvent 'showCardsManager'

      error: (xhr) ->
        util.showAjaxError(xhr.responseText)

      complete: ->
        console.log "Request Completed!"
        util.hideAjaxIndicator()

  showCardType: (e) ->
    $input = Backbone.$(e.currentTarget)
    cardType = util.getCreditCardType($input.val())
    $input.next().removeAttr('class').attr('class', 'wb-card-logo icon ' + cardType + 'CC')

  getCardDataAt: (cardIndex) ->
    @model.get('cards')[cardIndex]

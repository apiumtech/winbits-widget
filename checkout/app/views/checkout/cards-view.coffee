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
  amexSupported: yes
  cybersourceSupported: yes

  initialize: ->
    super
    @delegate 'click', '.wbc-edit-card-link', -> @editCard.apply(@, arguments)
    @subscribeEvent 'loggedOut', @resetModel

  resetModel: ->
    @model.clear()

  attach: ->
    super
    that = @

    @$el.find(".wb-card-number-input").on "blur",  (e)->
      that.showCardType(e)

    @$el.find(".wb-card-number-input").on "textchange",  (e)->
      that.showCardType(e)

    @$el.find(".wb-delete-card-link").on "click",  (e)->
      that.confirmDeleteCard(e)

    @$el.find("#wbi-new-card-form").on "submit",  (e)->
      that.submitNewCardForm(e)

    @$el.find("#wbi-add-new-card-link").on "click",  (e)->
      util.renderSliderOnPayment(100, false)
      that.showNewCardForm(e)

    @$el.find(".wb-card-list-item").on "click",  (e)->
      that.selectCard(e)

    @$el.find(".wb-edit-card-link").on "click", (e) ->
      util.renderSliderOnPayment(100, false)
      that.showEditCardForm(e)

    @$el.find( "#wbi-edit-card-form").on "submit", (e) ->
        that.submitEditCardForm(e)

    @$el.find( ".wb-cancel-card-form-btn").on "click", (e) ->
        that.cancelSaveUpdateCard(e)

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
    #@$el.find('li.wb-amex-card').hide() if not @amexSupported
    #@$el.find('li.wb-cybersource-card').hide() if not @cybersourceSupported

  showNewCardForm: (e) ->
    e.preventDefault()
    $form = @$el.find('form#wbi-new-card-form')
    $form.validate().resetForm()
    @$el.find('#wbi-cards-list-holder').hide()
    $form.parent().show()

  cancelSaveUpdateCard: (e) ->
    e.preventDefault()
    
    util.renderSliderOnPayment(100, true)
    @publishEvent 'paymentFlowCancelled'
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
    $ = Winbits.$
    $form.validate().resetForm()
    formData = $.extend {}, cardInfo.cardData, cardInfo.cardAddress
    if formData.expirationYear and formData.expirationYear.length
      formData.expirationYear = formData.expirationYear.slice(-2)
    $.each formData, (key, value) ->
      $form.find('[name=' + key + ']').val value
    cardType = cardInfo.cardData.cardType.toLowerCase()
    $form.find('span.wb-card-logo').removeAttr('class').attr('class', 'wb-card-logo icon ' + cardType + 'CC')

    $form.find('[name=cardPrincipal]').prop 'checked', cardInfo.cardPrincipal is true

  submitNewCardForm: (e) ->
    e.preventDefault()
    $ = Winbits.$
    $form = $(e.currentTarget)
    newCardData = util.serializeForm($form)
    newCardData.cardPrincipal = newCardData.hasOwnProperty('cardPrincipal')
    $submitTriggers = $form.find('.wb-submit-trigger')
    if $form.valid()
      $submitTriggers.prop('disabled', true)
      util.showAjaxIndicator()
      that = @
      util.ajaxRequest( config.apiUrl + "/orders/card-subscription.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(paymentInfo: newCardData)
        headers:
          "Accept-Language": "es",
          "WB-Api-Token": util.retrieveKey(config.apiTokenName)
        success: (data) ->
          console.log ["Save new card success!", data]
          that.publishEvent 'showCardsManager'
        error: (xhr) ->
          util.showAjaxError(xhr.responseText)
        complete: ->
          console.log "Request Completed!"
          $submitTriggers.prop('disabled', false)
          util.hideAjaxIndicator()
      )

  submitEditCardForm: (e) ->
    e.preventDefault()
    $ = Winbits.$
    $form = $(e.currentTarget)
    currentCardData = $form.data('current-card-data')
    updatedCardData = util.serializeForm($form)
    updatedCardData.cardPrincipal = updatedCardData.hasOwnProperty('cardPrincipal')
    $submitTriggers = $form.find('.wb-submit-trigger').prop('disabled', true)
    util.showAjaxIndicator()
    that = @

    util.ajaxRequest( config.apiUrl + "/orders/card-subscription/" + currentCardData.subscriptionId + ".json",
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
#      context: { that: @, $form: $form, $submitTriggers: $submitTriggers }
      data: JSON.stringify(paymentInfo: updatedCardData)
      headers:
        "Accept-Language": "es",
        "WB-Api-Token": util.retrieveKey(config.apiTokenName)
      beforeSend: ->
        $form.valid()
      success: (data) ->
        console.log ["Update card success!", data]
        that.showCardsList()
        that.publishEvent 'showCardsManager'
      error: (xhr) ->
        util.showAjaxError(xhr.responseText)
      complete: ->
        console.log "Request Completed!"
        $submitTriggers.prop('disabled', false)
        util.hideAjaxIndicator()
    )

  confirmDeleteCard: (e) ->
    e.preventDefault()
    e.stopPropagation()
    $ = Winbits.$
    cardIndex = @$el.find(e.currentTarget).closest('li').index()
    cardInfo = @model.get('cards')[cardIndex].cardInfo
    answer = confirm '¿En verdad quieres eliminar la tarjeta ' + cardInfo.cardData.accountNumber + '?'
    if answer
      util.showAjaxIndicator('Eliminando tarjeta...')
      that = @
      util.ajaxRequest( config.apiUrl + "/orders/card-subscription/" + cardInfo.subscriptionId + ".json",
        type: "DELETE"
        dataType: "json"
#        context: { that: @, cardIndex: cardIndex }
        headers:
          "Accept-Language": "es",
          "WB-Api-Token": util.retrieveKey(config.apiTokenName)

        success: (data) ->
          console.log ["Delete card success!", data]
          cards = that.model.get 'cards'
          cards.splice(cardIndex, 1)
          that.render()
        error: (xhr) ->
          util.showAjaxError(xhr.responseText)
        complete: ->
          util.hideAjaxIndicator()
      )

  selectCard: (e) ->
    e.preventDefault()
    $selectedCard = @$el.find(e.currentTarget)
    if not ( $selectedCard.is('.creditcardSelected') or $selectedCard.is('.creditcardNotEligible') )
      $selectedCard.siblings('.creditcardSelected').removeClass('creditcardSelected')
      $selectedCard.addClass('creditcardSelected')
      cardIndex = $selectedCard.index()
      cardInfo = @model.get('cards')[cardIndex].cardInfo
      @publishEvent 'cardSelected', { cardIndex: cardIndex, cardInfo: cardInfo }
      if @model.mainOnClick
        @setMainCard cardInfo

  setMainCard: (cardInfo) ->
    $ = Winbits.$
    util.showAjaxIndicator('Estableciendo tarjeta principal...')
    that = @
    url = config.apiUrl + "/orders/card-subscription/" + cardInfo.subscriptionId + "/main.json"
    util.ajaxRequest( url,
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
#      context: { that: @ }
      headers:
        "Accept-Language": "es",
        "WB-Api-Token": util.retrieveKey(config.apiTokenName)

      success: (data) ->
        console.log ["Update main card success!", data]
        that.publishEvent 'showCardsManager'
      error: (xhr) ->
        util.showAjaxError(xhr.responseText)
      complete: ->
        console.log "Request Completed!"
        util.hideAjaxIndicator()
    )
  showCardType: (e) ->
    $input = Winbits.$(e.currentTarget)
    cardType = util.getCreditCardType($input.val())
    $input.next().removeAttr('class').attr('class', 'wb-card-logo icon ' + cardType + 'CC')

  getCardDataAt: (cardIndex) ->
    @model.get('cards')[cardIndex]

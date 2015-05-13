View = require 'views/base/view'
template = require 'views/templates/checkout/cards'
util = require 'lib/util'
vendor = require 'lib/vendor'
config = require 'config'
mediator = require 'chaplin/mediator'
CardsComplete = require "models/checkout/cards"

# Site view is a top-level view which is bound to body.
module.exports = class CardsView extends View
  container: '#wbi-cards'
  containerMethod: 'prepend'
  autoRender: yes
  template: template
  amexSupported: yes
  cybersourceSupported: yes
  window.completeCardData = []

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
    
    @$el.find( "#wbi-copy-address").on "click", (e) ->
      that.doCopyAddress()

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
          validateCreditCardDate:true
        expirationYear:
          required: true
          minlength: 2
          digits: true
          validateCreditCardDate:true
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
        phoneNumber:
          required: true
          minlength: 10
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
    console.log 'crea tarjeta', mediator.profile.mainAddress
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

    @cardsComplete = new CardsComplete
    @cardsComplete.getCardsCompleteFromCyberSource(cardInfo.subscriptionId)
      .done @completeCardSuccess

    $form.data('current-card-data', cardInfo)
    $form.data('current-card-index', cardIndex)
    @fillEditCardForm $form, window.completeCardData.response
    @$el.find('#wbi-cards-list-holder').hide()
    $form.parent().show()


  completeCardSuccess: (data)->
    window.completeCardData = data



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
    delete newCardData['copyAddress']
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
          util.renderSliderOnPayment(100, true)
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
    if $form.valid()
      $submitTriggers.prop('disabled', true)
      util.showAjaxIndicator()
      that = @
  
      util.ajaxRequest( config.apiUrl + "/orders/card-subscription/" + currentCardData.subscriptionId + ".json",
        type: "PUT"
        contentType: "application/json"
        dataType: "json"
        context: { that: @, $form: $form, $submitTriggers: $submitTriggers }
        data: JSON.stringify(paymentInfo: updatedCardData)
        headers:
          "Accept-Language": "es",
          "WB-Api-Token": util.retrieveKey(config.apiTokenName)
        beforeSend: ->
          $form.valid()
        success: (data) ->
          console.log ["Update card success!", data]
          that.showCardsList()
          util.renderSliderOnPayment(100, true)
          that.publishEvent 'showCardsManager'
        error: (xhr) ->
          util.showAjaxError(xhr.responseText)
        complete: ->
          console.log "Request Completed!"
          $submitTriggers.prop('disabled', false)
          util.hideAjaxIndicator()
      )

    $submitTriggers.prop('disabled', false)

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
  
  doCopyAddress:(e) ->
    if @$('#wbi-copy-address').prop('checked') is yes
      @fillCardWithMain()
    else
      @cleanCardData()
  
  fillCardWithMain: ->
    mainAddress = mediator.profile.mainAddress
    if mainAddress isnt null
      @$('#wbi-new-card-firstName').val(mainAddress.firstName)
      lastName = @obtainFullLastName(mainAddress.lastName, mainAddress.lastName2)
      @$('#wbi-new-card-lastName').val(lastName) 
      @$('#wbi-new-card-street').val(mainAddress.street)
      fullNumber = @obtainFullNumber(mainAddress.externalNumber, mainAddress.internalNumber)
      @$('#wbi-new-card-number').val(fullNumber)
      @$('#wbi-new-card-city').val(mainAddress.county)
      @$('#wbi-new-card-state').val(mainAddress.state)
      @$('#wbi-new-card-postalCode').val(mainAddress.zipCode)
      @$('#wbi-new-card-phoneNumber').val(mainAddress.phone)
  
  cleanCardData: ->
      @$('#wbi-new-card-firstName').val('')
      @$('#wbi-new-card-lastName').val('') 
      @$('#wbi-new-card-street').val('')
      @$('#wbi-new-card-number').val('')
      @$('#wbi-new-card-city').val('')
      @$('#wbi-new-card-state').val('')
      @$('#wbi-new-card-postalCode').val('')
      @$('#wbi-new-card-phoneNumber').val('')
 
  obtainFullLastName:(lastName, lastName2) ->
    fullLastName = lastName
    if lastName2
      fullLastName = lastName + ' ' + lastName2
    fullLastName

  obtainFullNumber: (intNumber, extNumber) ->    
    fullNumber = intNumber
    if extNumber
      fullNumber = intNumber + ' ' + extNumber    
    fullNumber  

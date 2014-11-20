ChkController = require 'controllers/checkout-controller'
ChaplinMediator = require 'chaplin/mediator'
config = require 'config'
util = require 'lib/util'
EventBroker = require 'chaplin/lib/event_broker'
validators = require 'lib/validators'

#routes = require 'routes'
#_ = require 'underscore'
#console.log _

# The application object.
module.exports = class Application
  # Set your application name here so the document title is set to
  # “Controller title – Site title” (see Chaplin.Layout#adjustTitle)
  #title: 'Brunch example application'

  initialize: (checkout)->
    @initBackbone()
    @initMomentTimeZone()
    Winbits.isCrapBrowser = util.isCrapBrowser

    @initCustomRules()

    @initChkControllers()

    # Mediator is a global message broker which implements pub / sub pattern.
    @initMediator()

    Object.freeze? this

    Winbits.env = get: -> config.apiUrl

  # Create additional mediator properties.
  initMediator: ->
    # Add additional application-specific properties and methods
    # e.g. Chaplin.mediator.prop = null

    # Seal the mediator.
    ChaplinMediator.flags = {}
    ChaplinMediator.facebook = {}
    ChaplinMediator.profile = {}
    ChaplinMediator.global = {}
    ChaplinMediator.post_checkout = {}
    ChaplinMediator.seal()

  initChkControllers: ->
    if util.isCrapBrowser()
      @initXDMRpc remote: Winbits.checkoutConfig.providerUrl
    util.storeKey(config.apiTokenName, Winbits.token)
    delete Winbits.token
    # These controllers are active during the whole application runtime.
    @chkController = new ChkController()
    @chkController.index()

  initBackbone: ->
    # Enable support for PUT & DELETE requests
    # Backbone.emulateHTTP = yes
    # Proxy Backbone's ajax request function to use the easyXDM rpc on IE8-9
    # This enables Backbone's fetch to use the RPC
    Backbone.ajax = () ->
      util.ajaxRequest.apply(Backbone.$, arguments)

  initXDMRpc: (config) ->
    Winbits.rpc = new easyXDM.Rpc(config,
      remote:
        request: {}
        getTokens: {}
        saveApiToken: {}
        storeVirtualCart: {}
        logout: {}
        saveUtms: {}
        getUtms: {}
        facebookStatus: {}
        facebookMe: {}
        saveUtms: {}
        getUtms: {}
    )

  initMomentTimeZone: ->
    moment.tz.add
      zones:
        "America/Mexico_City": [
          "-6:36:36 - LMT 1922_0_1_0_23_24 -6:36:36",
          "-7 - MST 1927_5_10_23 -7",
          "-6 - CST 1930_10_15 -6",
          "-7 - MST 1931_4_1_23 -7",
          "-6 - CST 1931_9 -6",
          "-7 - MST 1932_3_1 -7",
          "-6 Mexico C%sT 2001_8_30_02 -5",
          "-6 - CST 2002_1_20 -6",
          "-6 Mexico C%sT"
        ]
      rules:
        Mexico: [
          "1939 1939 1 5 7 0 0 1 D",
          "1939 1939 5 25 7 0 0 0 S",
          "1940 1940 11 9 7 0 0 1 D",
          "1941 1941 3 1 7 0 0 0 S",
          "1943 1943 11 16 7 0 0 1 W",
          "1944 1944 4 1 7 0 0 0 S",
          "1950 1950 1 12 7 0 0 1 D",
          "1950 1950 6 30 7 0 0 0 S",
          "1996 2000 3 1 0 2 0 1 D",
          "1996 2000 9 0 8 2 0 0 S",
          "2001 2001 4 1 0 2 0 1 D",
          "2001 2001 8 0 8 2 0 0 S",
          "2002 9999 3 1 0 2 0 1 D",
          "2002 9999 9 0 8 2 0 0 S"
        ]
      links: {}
    moment().tz("America/Mexico_City").format();

   #add new method for validation
  initCustomRules: ()->
    Winbits.$.validator.addMethod("zipCodeDoesNotExist", (value, element) ->
      $element = Winbits.$(element)
      data = $element.data('_zip-code-not-found-error')
      data isnt yes
    ,"Este código postal no existe.")

    Winbits.$.validator.addMethod("wbiSelectInfo", (value, element) ->
      $zipCode = Winbits.$(element).parent().parent().find('input[name=zipCode]')
      if($zipCode.val())
        value.length >= 1
      else
        yes
    ,"Selecccione una opción valida")

    Winbits.$.validator.addMethod("wbiLocation", (value, element) ->
      $element = Winbits.$(element)
      if $element.is(':visible')
        if !$element.val() then no else yes
      else
        yes
    ,"Campo es requerido.")
    
    Winbits.$.validator.addMethod("wbiPhone", (value) ->
      if value
        /^[0-9]{10,15}/.test value
      else
        yes
    ,"Ingresa un número telefónico válido.")

    Winbits.$.validator.addMethod("wbiSupportInstallments", (value, element, params) ->
      url = "#{config.apiUrl}/orders/cards/support-installment?accountNumber=#{value}"
      validMsiCard = yes  
      defaults =
        type: "GET"
        contentType: "application/json"
        dataType: "json"
        headers:
          "Accept-Language": "es"

      util.ajaxRequest(
        url:url 
        options: defaults,
        success: (data) ->
          respuesta=
            responseJSON: data
          validators.successSupportInstallment respuesta, params.paymentMethod, params.selector
      )

      validMsiCard  
    ,"La tarjeta no soporta meses sin intereses.")



    Winbits.$.fn.wbCreditCardDate = ()->
      $this = Winbits.$(this)
      month = $this.find('#expirationMonth').val()
      month = '0' + month if month and month.length == 1
      year = $this.find('#expirationYear').val()
      "#{year}-#{month}"


    Winbits.$.validator.addMethod 'validateCreditCardDate', (value, element)->
      val = Winbits.$(element).parent().wbCreditCardDate()
      if val >= moment().format('YY-MM')
        Winbits.$(element).parent().find('.error').removeClass('error')
        yes
      else
        no
    , "Escribe una fecha válida."

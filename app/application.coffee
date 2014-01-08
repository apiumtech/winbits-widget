HomeController = require 'controllers/home-controller'
ChkController = require 'controllers/checkout-controller'
ChaplinMediator = require 'chaplin/mediator'
LoginUtil = require 'lib/loginUtil'
ProxyHandlers = require 'lib/proxyHandlers'
config = require 'config'
util = require 'lib/util'
EventBroker = require 'chaplin/lib/event_broker'
token = require 'lib/token'

#routes = require 'routes'
#_ = require 'underscore'
#console.log _

# The application object.
module.exports = class Application
  # Set your application name here so the document title is set to
  # “Controller title – Site title” (see Chaplin.Layout#adjustTitle)
  #title: 'Brunch example application'

  initialize: (checkout)->
    if not checkout
      console.log ['WINBITS', window.Winbits]
      w$.extend config, Winbits.userConfig or {}
#      window.Winbits = {}
      @initHomeControllers()
    else
      @initChkControllers()


    # Mediator is a global message broker which implements pub / sub pattern.
    @initMediator()

    Object.freeze? this

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

  initHomeControllers: ->
    Winbits.$(window.document).on 'winbitsrpcready', () ->
      console.log 'Publishing event proxyLoaded'
      EventBroker.publishEvent('proxyLoaded')
    # These controllers are active during the whole application runtime.
    @loginUtil = new LoginUtil()
    @proxyHandlers = new ProxyHandlers()
    @homeController = new HomeController()
    @homeController.index()
    token.requestTokens(Winbits.$)

  initChkControllers: ->
    util.storeKey(config.apiTokenName, Winbits.token)
    delete Winbits.token
    # These controllers are active during the whole application runtime.
    @chkController = new ChkController()
    @chkController.index()

HomeController = require 'controllers/home-controller'
ChkController = require 'controllers/checkout-controller'
ChaplinMediator = require 'chaplin/mediator'
LoginUtil = require 'lib/loginUtil'
ProxyHandlers = require 'lib/proxyHandlers'
config = require 'config'

#routes = require 'routes'
#_ = require 'underscore'
#console.log _

# The application object.
module.exports = class Application
  # Set your application name here so the document title is set to
  # “Controller title – Site title” (see Chaplin.Layout#adjustTitle)
  #title: 'Brunch example application'

  initialize: (checkout)->
    #console.log config
    #console.log window.Winbits

    if not checkout
      w$.extend config, Winbits.userConfig or {}
      window.Winbits = {}
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
    ChaplinMediator.proxy = {}
    ChaplinMediator.profile = {}
    ChaplinMediator.seal()


  initHomeControllers: ->
    # These controllers are active during the whole application runtime.
    @loginUtil = new LoginUtil()
    @proxyHandlers = new ProxyHandlers()
    @homeController = new HomeController()
    @homeController.index()

  initChkControllers: ->
    # These controllers are active during the whole application runtime.
    @chkController = new ChkController()
    @chkController.index()

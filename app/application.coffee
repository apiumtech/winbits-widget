HomeController = require 'controllers/home-controller'
ChaplinMediator = require 'chaplin/mediator'
LoginUtil = require 'lib/loginUtil'
ProxyHandlers = require 'lib/proxyHandlers'

#routes = require 'routes'
#_ = require 'underscore'
#console.log _

# The application object.
module.exports = class Application
  # Set your application name here so the document title is set to
  # “Controller title – Site title” (see Chaplin.Layout#adjustTitle)
  #title: 'Brunch example application'

  initialize: ->
    Window.Winbits = {}
    @initControllers()

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
    ChaplinMediator.seal()

    @loginUtil = new LoginUtil()
    @proxyHandlers = new ProxyHandlers()
  initControllers: ->
    # These controllers are active during the whole application runtime.
    @homeController = new HomeController()
    @homeController.index()

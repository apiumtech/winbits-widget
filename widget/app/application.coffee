routes = require './routes'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$

# The application object.
module.exports = class Application extends Chaplin.Application
  # Set your application name here so the document title is set to
  # “Controller title – Site title” (see Chaplin.Layout#adjustTitle)
  #title: 'Concept test'

  initialize: ->
    super

  initMediator: ->
    # Add additional application-specific properties and methods
    # e.g. Chaplin.mediator.prop = null

    # Seal the mediator.
    mediator.seal()
    super

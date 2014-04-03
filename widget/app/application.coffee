routes = require './routes'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator

# The application object.
module.exports = class Application extends Chaplin.Application
  # Set your application name here so the document title is set to
  # “Controller title – Site title” (see Chaplin.Layout#adjustTitle)
  #title: 'Concept test'

  initialize: ->
    super
    Winbits.isCrapBrowser = utils.isCrapBrowser

  initMediator: ->
    # Add additional application-specific properties and methods
    # e.g. Chaplin.mediator.prop = null

    cls = ->
      data = 'login-data': Winbits.env.get 'login-data'
      {
        get: (property)->
          data[property]
        set: (property, value)->
          data[property] = value
      }

    mediator.data = cls()
    console.log ['Mediator initialized']

    # Seal the mediator.
    mediator.seal()
    super

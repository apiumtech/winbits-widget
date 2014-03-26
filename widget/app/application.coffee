routes = require './routes'
util = require 'lib/util'


# The application object.
module.exports = class Application extends Chaplin.Application
  # Set your application name here so the document title is set to
  # “Controller title – Site title” (see Chaplin.Layout#adjustTitle)
  title: 'Concept test'

  initialize: ->
    super
    Winbits.isCrapBrowser = util.isCrapBrowser

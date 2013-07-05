ChaplinController = require 'chaplin/controller/controller'
SiteView = require 'views/site-view'
#HeaderView = require 'views/header-view'

module.exports = class Controller extends ChaplinController
  beforeAction: ->
    SiteView.render()

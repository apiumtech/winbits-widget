

utils = require 'lib/utils'
NotLoggedInController = require 'controllers/not-logged-in-controller'
NewsregisterModalView = require 'views/newsregister/newsregister-modal-view'


module.exports = class NewsregisterController extends NotLoggedInController

  beforeAction: ->
    super

  index:->
    console.log 'newsregister#index'
    @view = new NewsregisterModalView
View = require 'views/base/view'
template = require 'views/templates/account/cards-manager'
util = require 'lib/util'
vendor = require 'lib/vendor'
config = require 'config'
mediator = require 'chaplin/mediator'

# Site view is a top-level view which is bound to body.
module.exports = class CardsManagerView extends View
  container: '.widgetWinbitsMain'
  autoRender: yes
  template: template

  initialize: ->
    super
    console.log "CardsManagerView#initialize"
    @delegate 'click', '.wb-back-to-site', @backToSite

    @subscribeEvent 'loggedOut', @resetView

  resetView: ->
    if @model?
      @model.clear()
    @render()

  attach: ->
    super
    console.log "CardsManagerView#attach"
    @$el.find("#wbi-cards-manager").hide()

  backToSite: (e) ->
    e.preventDefault()
    util.backToSite(e)

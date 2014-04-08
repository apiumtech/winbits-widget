View = require 'views/base/view'
Routes = require 'routes'
Header = require 'models/header/header'
env = Winbits.env
$ = Winbits.$

module.exports = class HeaderView extends View
  container: Winbits.env.get 'widget-container'
  template: require './templates/header'

  initialize: ->
    super
    headerData =
      currentVerticalId: env.get 'current-vertical-id'
      verticalsData: env.get 'verticals-data'
    @model = new Header headerData

  attach: ->
    super
    console.log "header-view#attach"
    @$('.wbc-default-action', '#wbi-message-modal').click -> $.fancybox.close()

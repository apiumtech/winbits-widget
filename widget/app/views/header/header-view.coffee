View = require 'views/base/view'
Routes = require 'routes'

module.exports = class HeaderView extends View
  container: Winbits.config.widgetContainer
  template: require './templates/header'

  attach: ->
    super
    console.log "header page view attach"


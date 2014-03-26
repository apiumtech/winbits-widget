View = require 'views/base/view'
Routes = require 'routes'

module.exports = class HeaderView extends View
  container: Winbits.config.widgetContainer
  autoRender:true
  className: 'wbc-header'
  template: require './templates/header'
  autoAttach: true

  attach: ->
    super
    console.log "header page view attach"


View = require 'views/base/view'
Routes = require 'routes'

module.exports = class HeaderView extends View
  container: Winbits.env.get 'widget-container'
  template: require './templates/header'

  attach: ->
    super
    console.log "header page view attach"


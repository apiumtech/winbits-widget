View = require 'views/base/view'
Routes = require 'routes'
$ = Winbits.$

module.exports = class HeaderView extends View
  container: Winbits.env.get 'widget-container'
  template: require './templates/header'

  attach: ->
    super
    console.log "header page view attach"
    @$('.wbc-default-action', '#wbi-message-modal').click -> $.fancybox.close()

  render: ->
    super
    console.log "header page view render"


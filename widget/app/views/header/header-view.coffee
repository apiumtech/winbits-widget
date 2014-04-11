View = require 'views/base/view'
Header = require 'models/header/header'
env = Winbits.env
$ = Winbits.$

module.exports = class HeaderView extends View
  container: env.get 'widget-container'
  template: require './templates/header'
  model: new Header
    currentVerticalId: env.get 'current-vertical-id'
    verticalsData: env.get 'verticals-data'
    currentVertical: env.get 'current-vertical'

  initialize: ->
    super

  attach: ->
    super
    console.log "header-view#attach"
    @$('.openClose').showHideDiv();
    @$('.wbc-default-action', '#wbi-message-modal').click -> $.fancybox.close()

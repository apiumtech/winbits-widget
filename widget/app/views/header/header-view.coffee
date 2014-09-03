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
    @$('.openClose').showHideDiv()
    $body = $('body')
    for selector in ['#fancybox-overlay', '#fancybox-wrap', '.wbc-propagation-stopper']
      $body.on('click', selector, @stopPropagationHandler)

  stopPropagationHandler: (e) ->
    e.stopPropagation()

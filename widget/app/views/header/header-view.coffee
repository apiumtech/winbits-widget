View = require 'views/base/view'
Header = require 'models/header/header'
HeaderBannerView = require 'views/header/banner-view'
mediator = Winbits.Chaplin.mediator
utils = require 'lib/utils'
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
    @getPromotions()
    @subscribeEvent 'logged-in', @eventToRender
    @subscribeEvent 'log-out', @eventToRender

  attach: ->
    super
    @$('.openClose').showHideDiv()
    @delegate 'click','#wbi-banner-promo', @redirectPromoModal
    $body = $('body')
    for selector in ['#fancybox-overlay', '#fancybox-wrap', '.wbc-propagation-stopper']
      $body.on('click', selector, @stopPropagationHandler)


  stopPropagationHandler: (e) ->
    e.stopPropagation()

  eventToRender: ->
    @render()

  redirectPromoModal:(e)->
    e.preventDefault()
    utils.redirectTo controller:'promo', action:'index'

  getPromotions : ->
     @model.getPromo(context: @)
       .done(@successPromo)
       .fail(@errorPromo)

  successPromo:(data)->
    @model.set('promo', data.response)
    if data.response
      mediator.data.set('modalUrl', data.response.modalUrl)
      @showModalPromo()

  errorPromo: ->
    @model.set('promo', null)

  showModalPromo: ->
    unless mediator.data.get('first-entry')
      env.get('rpc').firstEntry()
      mediator.data.set('first-entry', yes)
      utils.redirectTo controller:'promo', action:'index'



  render: ()->
    super
    @subview('banner-view', new HeaderBannerView model: @model)
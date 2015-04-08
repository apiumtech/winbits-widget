'use strict'
BaseController = require 'controllers/base/controller'
PromoModalView = require 'views/promo-modal/promo-modal-view'
PromoModal = require 'models/promo-modal/promo-modal'
utils = require 'lib/utils'
cartUtils = require 'lib/cart-utils'
mediator = Winbits.Chaplin.mediator
_ = Winbits._
$ = Winbits.$

module.exports = class PromoModalController extends BaseController

  beforeAction: ->
    super

  index: ()->

    modalUrl = mediator.data.get('modalUrl')
    if(modalUrl)
      @model = new PromoModal (modalUrl : modalUrl)
      @view = new PromoModalView(model: @model)
    else
      utils.redirectTo controller:'home', action:'index'

'use strict'
BaseController = require 'controllers/base/controller'
PromoModalView = require 'views/promo-modal/promo-modal-view'
utils = require 'lib/utils'
cartUtils = require 'lib/cart-utils'
_ = Winbits._
$ = Winbits.$

module.exports = class PromoModalController extends BaseController

  beforeAction: ->
    super

  index: ()->
    console.log ["Promo-Controller#index"]
    @view = new PromoModalView

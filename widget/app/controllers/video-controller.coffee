'use strict'
BaseController = require 'controllers/base/controller'
VideoModalView = require 'views/video-modal/video-modal-view'
utils = require 'lib/utils'
cartUtils = require 'lib/cart-utils'
_ = Winbits._
$ = Winbits.$

module.exports = class VideoModalController extends BaseController

  beforeAction: ->
    super

  index: ()->
    console.log ["Video-Controller#index"]
    @view = new VideoModalView

ChaplinModel = require 'chaplin/models/model'
config = require 'config'
util = require 'lib/util'
module.exports = class CardTokenPayment extends ChaplinModel

  initialize: () ->
    super

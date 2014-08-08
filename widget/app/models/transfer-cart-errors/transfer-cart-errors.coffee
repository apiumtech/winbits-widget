utils = require 'lib/utils'
Model = require "models/base/model"
env = Winbits.env
$ = Winbits.$

module.exports = class TransferCartErrors extends Model

    hasFailedCartDetails: ->
      @get('failedCartDetails')?

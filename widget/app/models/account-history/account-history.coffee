'use strict'
Model = require 'models/base/model'
utils = require 'lib/utils'
env = Winbits.env
$ = Winbits.$
_ = Winbits._
mediator = Winbits.Chaplin.mediator

module.exports = class AccountHistory extends Model

  initialize:(loginData = mediator.data.get 'login-data') ->
    super
    @set(@parse response: loginData) if loginData

  parse: (data)->
    profile = {pendingOrderCount: data.response.profile.pendingOrdersCount, bitsTotal: data.response.bitsBalance}

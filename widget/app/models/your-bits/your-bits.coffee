utils = require 'lib/utils'
Model = require "models/base/model"
env = Winbits.env
$ = Winbits.$

module.exports = class YourBitsModel extends Model
  url: env.get('api-url') + "/users/bits/transactions.json"
  needsAuth: true

  initialize: ->
    super

  parse: (data) ->
    console.log console.log ["META>>>>>>",data.meta]
    @meta = data.meta
    data.response


  getTotalTransactions: () ->
    @meta.totalTransactions
utils = require 'lib/utils'
Model = require "models/base/model"
env = Winbits.env
$ = Winbits.$

module.exports = class Mailing extends Model
  url: env.get('api-url') + "/users/bits/transactions.json"
  needsAuth: true

  initialize: ->
    super

  parse: (data) ->
    balance: data.response.balance
    transactions: data.response.transactions
    transactionsSize: data.response.transactions.length + 1

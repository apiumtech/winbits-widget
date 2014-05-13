'use strict'
Model = require 'models/base/model'
utils = require 'lib/utils'
env = Winbits.env
$ = Winbits.$
_ = Winbits._

module.exports = class Favorites extends Model
  url: env.get('api-url') + '/users/wish-list-items.json'
  needsAuth: true

  initialize: ->
    super

  parse: (data)->
    console.log ['parse model',data]
    if data.response and data.response.length >= 10
      @set 'brandTotal', true
      @set 'brandsHidden', data.response.slice(10, data.response.length)
      brands: data.response.slice(0, 10)
    else
      brands: data.response


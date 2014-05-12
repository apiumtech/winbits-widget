'use strict'
Model = require 'models/base/model'
utils = require 'lib/utils'
env = Winbits.env
$ = Winbits.$
_ = Winbits._

module.exports = class Favorites extends Model
  url: env.get('api-url') + '/users/wish-list-items.json'

  needAuth: yes

  parse: (data)->
    brands: data.response




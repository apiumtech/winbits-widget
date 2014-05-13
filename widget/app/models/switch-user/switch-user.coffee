'use strict'
require = Winbits.require
Model = require 'models/my-account/my-account'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$

module.exports = class SwitchUser extends Model

  initialize: (data = mediator.data.get('login-data'))->
    super
    @set 'switchUser', data.switchUser
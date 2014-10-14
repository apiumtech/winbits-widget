require = Winbits.require
utils = require 'lib/utils'
MyProfile = require 'models/my-profile/my-profile'
_ = Winbits._
$ = Winbits.$
env = Winbits.env
mediator = Winbits.Chaplin.mediator

module.exports = class CompleteRegister extends MyProfile

  initialize: ->
    super
    @unsubscribeAllEvents()

  parse: (data) ->
    profile = super
    profile.currentVerticalId = env.get 'current-vertical-id'
    profile.activeVerticals = env.get 'verticals-data'
    profile.cashbackForComplete = mediator.data.get('login-data').cashbackForComplete
    profile


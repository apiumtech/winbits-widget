require = Winbits.require
utils = require 'lib/utils'
Model = require 'models/base/model'
_ = Winbits._

module.exports = class LoggedIn extends Model
  url: Winbits.env.get('api-url') + '/users/profile.json'
  needsAuth: true

  initialize: (loginData)->
    super
    @set @parse response: loginData

  parse: (data) ->
    profile = _.clone(data.response.profile)
    profile.email = data.response.email
    profile.isMale = profile.gender is 'male'
    profile.isFemale = profile.gender is 'female'
    console.log ['PROFILE', profile]
    profile

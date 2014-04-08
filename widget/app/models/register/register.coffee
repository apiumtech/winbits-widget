Model = require 'models/base/model'

module.exports = class Register extends Model

  initialize: (data)->
    super
    @set data

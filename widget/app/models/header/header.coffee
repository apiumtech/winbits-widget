Model = require 'models/base/model'

module.exports = class Header extends Model

  initialize: (data)->
    super
    if data?.verticalsData
      @set @parse
        meta: currentVerticalId: data.currentVerticalId
        response: data.verticalsData

  parse: (data) ->
    currentVerticalId: data.meta.currentVerticalId
    activeVerticals: data.response

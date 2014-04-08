Model = require 'models/base/model'

module.exports = class Header extends Model

  initialize: (data)->
    super
    if data?.verticalsData
      @set @parse
        meta: currentVerticalId: data.currentVerticalId
        response: data.verticalsData

  parse: (data) ->
    result = (v for v in data.response when v.id is data.meta.currentVerticalId)
    currentVertical: result[0]
    activeVerticals: data.response

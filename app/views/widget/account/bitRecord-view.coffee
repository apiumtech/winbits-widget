template = require 'views/templates/account/bitsCredit'
View = require 'views/base/view'
util = require 'lib/util'

module.exports = class BitRecordView extends View
  autoRender: false
  container: '#bitRecordContent'
  template: template

  render: ->
    super

  initialize: ->
    super
    @subscribeEvent 'bitRecordReady', @handlerModelReady

  attach: ->
    super
    util.customSelect(@$('.select'))

  handlerModelReady: ->
      @render()
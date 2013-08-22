template = require 'views/templates/account/bitsCredit'
View = require 'views/base/view'
util = require 'lib/util'
vendor = require 'lib/vendor'

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
    vendor.customSelect(@$('.select'))

  handlerModelReady: ->
      @render()

'use strict'
SmsModalView = require 'views/sms/sms-modal-view'
utils = require 'lib/utils'

describe 'SmsModalViewSpec', ->

  beforeEach ->
    @view = new SmsModalView(autoAttach:no)
    sinon.stub(@view, 'showAsModal')
    @view.attach()

  afterEach ->
    @view.showAsModal.restore()
    @view.dispose()

  it 'Sms modal will be renderized', ->
    expect(@view.$('#wbi-sms-input')).to.exist
    expect(@view.$('#wbi-sms-button')).to.exist

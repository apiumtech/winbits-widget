'use strict'
SmsModalView = require 'views/sms/sms-modal-view'
utils = require 'lib/utils'

describe 'SmsModalViewSpec', ->

  before ->
    $.validator.setDefaults ignore: []

  after ->
    $.validator.setDefaults ignore: ':hidden'

  beforeEach ->
    @view = new SmsModalView(autoAttach:no)
    sinon.stub(@view, 'showAsModal')
    @view.attach()

  afterEach ->
    @view.showAsModal.restore()
    @view.dispose()

  it 'Sms modal will be renderized', ->
    expect(@view.$('.wbc-sms-modal-form')).to.exist
    expect(@view.$('#wbi-sms-input')).to.exist
    expect(@view.$('#wbi-sms-button')).to.exist

  it 'When click in button not call send function, input is empty',->
    @view.$('[name=mobile]').val('')
    sendFunction = sinon.stub(@view,'send')
    @view.$('#wbi-sms-button').click()
    expect(sendFunction).not.called

  it 'When click in button not call send function, input has letters',->
    @view.$('[name=mobile]').val('hola')
    sendFunction = sinon.stub(@view,'send')
    @view.$('#wbi-sms-button').click()
    expect(sendFunction).not.called

  it 'When click in button not call send function, input has 5 numbers',->
    @view.$('[name=mobile]').val('12345')
    sendFunction = sinon.stub(@view,'send')
    @view.$('#wbi-sms-button').click()
    expect(sendFunction).not.called

  it 'When click in button call send function, input has numbers',->
    @view.$('[name=mobile]').val('1234567890')
    @view.$('[name=carrier]').val('1')
    sendFunction = sinon.stub(@view,'send')
    @view.$('#wbi-sms-button').click()
    expect(sendFunction).called
'use strict'
ActivationMobileView = require 'views/activation-mobile/activation-mobile-view'
utils = require 'lib/utils'

describe 'ActivationMobileViewSpec', ->

  before ->
    $.validator.setDefaults ignore: []

  after ->
    $.validator.setDefaults ignore: ':hidden'

  beforeEach ->
    @view = new ActivationMobileView(autoAttach:no)
    sinon.stub(@view, 'showAsModal')
    @view.attach()

  afterEach ->
    @view.showAsModal.restore()
    @view.dispose()
    utils.redirectTo.restore?()

  it 'Sms modal will be renderized', ->
    expect(@view.$('.wbc-activation-mobile-form')).to.exist
    expect(@view.$('#wbi-activation-input')).to.exist
    expect(@view.$('#wbi-activation-button')).to.exist

  it 'When click in button not call send function, input is empty',->
    @view.$('[name=code]').val('')
    sendFunction = sinon.stub(@view,'send')
    @view.$('#wbi-activation-button').click()
    expect(sendFunction).not.called

  it 'When click in button not call send function, input has 3 numbers',->
    @view.$('[name=code]').val('123')
    sendFunction = sinon.stub(@view,'send')
    @view.$('#wbi-activation-button').click()
    expect(sendFunction).not.called

  it 'When click in button call send function, input has numbers',->
    @view.$('[name=code]').val('12345')
    sendFunction = sinon.stub(@view,'send')
    @view.$('#wbi-activation-button').click()
    expect(sendFunction).called

  it 'Change activation code click', ->
    sinon.stub(utils,'redirectTo').returns yes
    @view.$('#wbi-change-activation-mobile').click()
    expect(utils.redirectTo).called

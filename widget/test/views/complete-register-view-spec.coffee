CompleteRegisterView = require 'views/complete-register/complete-register-view'
utils =  require 'lib/utils'
$ = Winbits.$

describe 'CompleteRegisterViewSpec', ->
  'use strict'

  before ->
    $.validator.setDefaults({ ignore: [] });

  after ->
    $.validator.setDefaults({ ignore: ':hidden' });

  beforeEach ->
    @view = new CompleteRegisterView autoAttach: false
    sinon.stub(@view, 'showAsModal')
    @view.attach()

  afterEach ->
    @view.showAsModal.restore?()
    utils.ajaxRequest.restore?()
    @view.dispose()

  it 'complete register view rendered',  ->
    expect(@view.$el).has.id('wbi-complete-register-modal')
    expect(@view.$ '#wbi-complete-register-form').is.rendered

  it 'do request should succed to complete register', ->
    sinon.stub(utils, 'ajaxRequest').yieldsTo('success', {})
    successStub = sinon.stub(@view, 'doRegisterSuccess')
    @view.$('#wbi-register-button').click()
    expect(successStub).to.be.calledOnce
    expect(@view.$ '.error').to.not.exist

  it 'do not makes request if form invalid', ->
    ajaxRequestStub = sinon.stub(utils, 'ajaxRequest')
    @view.$('[name=password]').val('')
    @view.$('#wbi-register-button').click()

    expect(ajaxRequestStub).to.not.be.called

  it 'show validation errors if form invalid', ->
    @view.$('[name=password]').val('')
    @view.$('#wbi-register-button').click()

    expect(@view.$ '.error').to.exist

  it 'error is shown if api return error', ->
    xhr = responseText: '{"meta":{"message":"Todo es culpa de Layún!"}}'
    ajaxRequestStub = sinon.stub(utils, 'ajaxRequest').yieldsToOn('error', @view, xhr)
    @view.$('#wbi-register-button').click()

    expectAjaxArgs.call(@, ajaxRequestStub, "Todo es culpa de Layún!")

  it 'error is shown if request fail', ->
    xhr = responseText: 'Server error'
    ajaxRequestStub = sinon.stub(utils, 'ajaxRequest').yieldsToOn('error', @view, xhr)
    @view.$('#wbi-register-button').click()

    expectAjaxArgs.call(@, ajaxRequestStub, "El servidor no está disponible, por favor inténtalo más tarde.")

  expectAjaxArgs = (ajaxRequestStub, errorText)->
    ajaxConfigArg = ajaxRequestStub.args[0][1]
    expect(ajaxConfigArg).to.has.property('context', @view)
    expect(ajaxConfigArg).to.has.property('data')
    .that.contain('"verticalId":1')
    expect(@view.$ '.errorDiv p').to.has.text(errorText)

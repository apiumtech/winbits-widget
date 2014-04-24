LoginView = require 'views/login/login-view'
LoginModel = require 'models/login/login'
utils = require 'lib/utils'
$ = Winbits.$
email = 'test@winbits.com'
password = '123456'

describe 'LoginViewSpec', ->
  'use strict'

  before ->
    $.validator.setDefaults ignore: []

  after ->
    $.validator.setDefaults ignore: ':hidden'

  beforeEach ->
    currentVertical = id: 1, baseUrl: 'http://www.test-winbits.com', name: 'Winbits Test'
    sinon.stub(Winbits.env, 'get')
      .withArgs('current-vertical-id').returns(currentVertical.id)
      .withArgs('current-vertical').returns(currentVertical)
      .withArgs('verticals-data').returns([
        currentVertical,
        { id: 2, baseUrl: 'http://dev.mylooq.com', name: 'My LOOQ' }
      ])
    @model = new LoginModel
    @view = new LoginView model: @model, autoAttach: no
    sinon.stub(@view, 'showAsModal')
    @view.attach()
    @view.$('[name=email]').val email
    @view.$('[name=password]').val password

  afterEach ->
    @view.showAsModal.restore?()
    utils.ajaxRequest.restore?()
    Winbits.env.get.restore?()

    @view.dispose()

  it 'login view renderized', ->
    expect(@view.$el).to.has.id('wbi-login-modal')
    expect(@view.$ '#wbi-login-form').to.be.rendered

  it 'do login should succed to Login', ->
    sinon.stub(@model, 'requestLogin').returns TestUtils.promises.resolved
    successStub = sinon.stub(@view, 'doLoginSuccess')
    @view.$('#wbi-login-in-btn').click()

    expect(successStub).to.be.calledOnce
    expect(@view.$ '.error').to.not.be.rendered
    expect(@view.$ '#wbi-login-in-btn').to.has.prop 'disabled', no

  it 'do not makes request if form invalid', ->
    ajaxRequestStub = sinon.stub(utils, 'ajaxRequest')
    @view.$('[name=password]').val('')
    @view.$('#wbi-login-in-btn').click()

    expect(ajaxRequestStub).to.not.be.called

  it 'show validation errors if form invalid', ->
    @view.$('[name=password]').val('')
    @view.$('#wbi-login-in-btn').click()

    expect(@view.$ '.error').to.be.rendered

  it 'error is show if api return error', ->
    sinon.stub(@model, 'requestLogin').returns TestUtils.promises.rejected
    errorStub = sinon.stub(@view, 'doLoginError')
    @view.$('#wbi-login-in-btn').click()

    expect(errorStub).to.be.calledOnce
    expect(@view.$ '#wbi-login-in-btn').to.has.prop 'disabled', no


  it 'error is shown if request fail', ->
    sinon.stub(@model, 'requestLogin').returns TestUtils.promises.rejected
    errorStub = sinon.stub(@view, 'doLoginError')
    @view.$('#wbi-login-in-btn').click()

    expect(errorStub).to.be.calledOnce
    expect(@view.$ '#wbi-login-in-btn').to.has.prop 'disabled', no

  it 'should publish event facebook-button-event', ->
    stub = sinon.stub @view, 'publishEvent'
    @view.$('#wbi-login-facebook-btn').click()
    expect(stub).to.be.calledOnce

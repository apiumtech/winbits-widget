LoginView = require 'views/login/login-view'
LoginModel = require 'models/login/login'
utils = require 'lib/utils'
$ = Winbits.$
email = 'test@winbits.com'
password = '123456'

describe 'LoginView', ->
  'use strict'

  before ->
    $.validator.setDefaults ignore: []

  after ->
    $.validator.setDefaults ignore: ':hidden'

  beforeEach ->
    @view = new LoginView autoAttach: no
    sinon.stub(@view, 'showAsModal')
    @view.attach()
    @view.$('[name=email]').val email
    @view.$('[name=password]').val password

  afterEach ->
    @view.showAsModal.restore?()
    utils.ajaxRequest.restore?()
    LoginModel.requestLogin.restore?()

    @view.dispose()

  it 'login view renderized', ->
    expect(@view.$el).to.has.id('wbi-login-modal')
    expect(@view.$ '#wbi-login-form').to.be.rendered

  it 'do login should succed to Login', ->
    sinon.stub(LoginModel,'requestLogin').yieldsTo('done',{})
#    sinon.stub(utils, 'ajaxRequest').yieldsTo('success', {})
    successStub = sinon.stub(@view, 'doLoginSuccess')
    @view.$('#wbi-login-in-btn').click()

    expect(successStub).to.be.calledOnce
    expect(@view.$ '.error').to.not.be.rendered

  it 'do not makes request if form invalid', ->
    ajaxRequestStub = sinon.stub(utils, 'ajaxRequest')
    @view.$('[name=password]').val('')
    @view.$('#wbi-login-in-btn').click()

    expect(ajaxRequestStub).to.not.be.called

  it 'show validation errors if form invalid', ->
    @view.$('[name=password]').val('')
    @view.$('#wbi-login-in-btn').click()

    expect(@view.$ '.error').to.be.rendered

  it 'error is shown if api return error', ->
    xhr = responseText: '{"meta":{"message":"Todo es culpa de Layún!"}}'
    sinon.stub(LoginModel,'requestLogin').yieldsTo('fail',{})
    ajaxRequestStub = sinon.stub(utils, 'ajaxRequest').yieldsToOn('error', @view, xhr)
    @view.$('#wbi-login-in-btn').click()

    expectAjaxArgs.call(@, ajaxRequestStub, "Todo es culpa de Layún!")

  it 'error is shown if request fail', ->
    xhr = responseText: 'Server error'
    sinon.stub(LoginModel,'requestLogin').yieldsTo('fail',{})
    ajaxRequestStub = sinon.stub(utils, 'ajaxRequest').yieldsToOn('error', @view, xhr)
    @view.$('#wbi-login-in-btn').click()

    expectAjaxArgs.call(@, ajaxRequestStub, "El servidor no está disponible, por favor inténtalo más tarde.")

  expectAjaxArgs = (ajaxRequestStub, errorText)->
    ajaxConfigArg = ajaxRequestStub.args[0][1]
    expect(ajaxConfigArg).to.has.property('context', @view)
    expect(ajaxConfigArg).to.has.property('data')
    .that.contain('"verticalId":1')
    expect(@view.$ '.errorDiv p').to.has.text(errorText)

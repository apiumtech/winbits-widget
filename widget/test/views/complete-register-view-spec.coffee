CompleteRegisterView = require 'views/complete-register/complete-register-view'
CompleteRegisterModel = require 'models/complete-register/complete-register'
utils =  require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$

describe 'CompleteRegisterViewSpec', ->
  'use strict'

  before ->
    $.validator.setDefaults({ ignore: [] });

  after ->
    $.validator.setDefaults({ ignore: ':hidden' });

  beforeEach ->
    @loginData =
      id: 19
      apiToken: '6ue7zrBfNkxgNTvT4ReGpuh55yjNLRl6qEHiXMFyXFx6M3ymV21EaARwilDZK0zM'
      bitsBalance: 0
    mediator.data.set 'login-data', @loginData
    @model = new CompleteRegisterModel name:'name', lastName:'lastName',profile: {}
    @view = new CompleteRegisterView model:@model, autoAttach: no
    sinon.stub(@view, 'showAsModal')
    @view.attach()

  afterEach ->
    @view.showAsModal.restore()
    utils.ajaxRequest.restore?()
    mediator.data.clear()
    @view.dispose()

  it 'complete register view rendered',  ->
    expect(@view.$el).has.id('wbi-complete-register-modal')
    expect(@view.$ '#wbi-complete-register-form').is.rendered

  it 'do request should succed to complete register', ->
    sinon.stub(@model, 'requestUpdateProfile').returns TestUtils.promises.resolved
    successStub = sinon.stub(@view, 'doCompleteRegisterSuccess')
    @view.$('#wbi-complete-register-btn').click()
    expect(successStub).to.be.calledOnce
    expect(@view.$ '.error').to.not.exist

  it 'do not makes request if form invalid', ->
    ajaxRequestStub = sinon.stub(utils, 'ajaxRequest')
    @view.$('[name=phone]').val('12312')
    @view.$('#wbi-complete-register-btn').click()
    expect(ajaxRequestStub).to.not.be.called

  it 'show validation errors if form invalid', ->
    @view.$('[name=phone]').val('qweqw')
    @view.$('#wbi-complete-register-btn').click()
    expect(@view.$ '.error').to.exist

  it 'error is shown if api return error', ->
    sinon.stub(@model, 'requestUpdateProfile').returns TestUtils.promises.rejected
    errorStub = sinon.stub(@view, 'doCompleteRegisterError')
    @view.$('#wbi-complete-register-btn').click()

    expect(errorStub).to.be.calledOnce
    expect(@view.$ '#wbi-complete-register-btn').to.has.prop 'disabled', no

  it 'error is shown if request fail', ->
    xhr = responseText: 'Server error'
    sinon.stub(@model, 'requestUpdateProfile').returns TestUtils.promises.rejected
    errorStub = sinon.stub(@view, 'doCompleteRegisterError')
    @view.$('#wbi-complete-register-btn').click()

    expect(errorStub).to.be.calledOnce
    expect(@view.$ '#wbi-complete-register-btn').to.has.prop 'disabled', no




  it 'show validation errors if day is invalid', ->
    @view.$('#wbi-birthdate-day').val('99')
    @view.$('#wbi-birthdate-month').val('12')
    @view.$('#wbi-birthdate-year').val('99')
    @view.$('#wbi-complete-register-btn').click()
    expect(@view.$ '.error').to.exist

  it 'show validation errors if month is invalid', ->
    @view.$('#wbi-birthdate-day').val('12')
    @view.$('#wbi-birthdate-month').val('99')
    @view.$('#wbi-birthdate-year').val('02')
    @view.$('#wbi-complete-register-btn').click()
    expect(@view.$ '.error').to.exist

  it 'show validation errors if day and month is invalid', ->
    @view.$('#wbi-birthdate-day').val('99')
    @view.$('#wbi-birthdate-month').val('99')
    @view.$('#wbi-birthdate-year').val('02')
    @view.$('#wbi-complete-register-btn').click()
    expect(@view.$ '.error').to.exist

  it 'no show validation errors if date is valid', ->
    @view.$('#wbi-birthdate-day').val('18')
    @view.$('#wbi-birthdate-month').val('02')
    @view.$('#wbi-birthdate-year').val('02')
    sinon.stub(@model, 'requestUpdateProfile').returns TestUtils.promises.resolved
    successStub = sinon.stub(@view, 'doCompleteRegisterSuccess')
    @view.$('#wbi-complete-register-btn').click()
    expect(successStub).to.be.calledOnce
    expect(@view.$ '.error').to.not.exist

CompleteRegisterView = require 'views/complete-register/complete-register-view'
CompleteRegisterModel = require 'models/complete-register/complete-register'
utils =  require 'lib/utils'
testUtils = require 'test/lib/test-utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
registerName = "name"
registerLastname = "lastname"
registerBirthdayDay = "11"
registerBirthdayMonth = "11"
registerBirthdayYear = "11"
registerZipCode = "12345"
registerZipCodeInfo = "Colonia"
registerLocation = "location"

describe 'CompleteRegisterViewSpec', ->
  'use strict'

  before ->
    $.validator.setDefaults({ ignore: [] });
    sinon.stub($, 'ajax').returns(testUtils.promiseResolvedWithData())

  after ->
    $.validator.setDefaults({ ignore: ':hidden' });
    $.ajax.restore()

  beforeEach ->
    @loginData =
      id: 19
      apiToken: '6ue7zrBfNkxgNTvT4ReGpuh55yjNLRl6qEHiXMFyXFx6M3ymV21EaARwilDZK0zM'
      bitsBalance: 0
      profile:
        completeRegister:0
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
    @view.$('#wbi-birthdate-day').val registerBirthdayDay
    @view.$('#wbi-birthdate-month').val registerBirthdayMonth
    @view.$('#wbi-birthdate-year').val registerBirthdayYear
    @view.$('#wbi-complete-register-zipCode').val registerZipCode
    @view.$('.wbc-gender-male').prev().addClass('radio-selected')
    @view.render()
    sinon.stub(@model, 'requestUpdateProfile').returns TestUtils.promises.resolved
    console.log ["Form", @view.$('#wbi-complete-register-form').valid()]
    successStub = sinon.stub(@view, 'doCompleteRegisterSuccess')
    @view.$('#wbi-complete-register-btn').click()
    expect(successStub).to.be.calledOnce
    expect(@view.$ '.error').to.not.exist

  it 'do not makes request if form invalid', ->
    doRequestUpdateProfile = sinon.stub(@model, 'requestUpdateProfile').returns TestUtils.promises.rejected
    @view.$('#wbi-complete-register-btn').click()
    expect(doRequestUpdateProfile).to.not.be.called

  it 'show validation errors if form invalid', ->
    @view.$('#wbi-complete-register-btn').click()
    expect(@view.$ '.error').to.exist

  it 'error is shown if api return error', ->
    @view.$('#wbi-birthdate-day').val registerBirthdayDay
    @view.$('#wbi-birthdate-month').val registerBirthdayMonth
    @view.$('#wbi-birthdate-year').val registerBirthdayYear
    @view.$('#wbi-complete-register-zipCode').val registerZipCode
    @view.$('.wbc-gender-male').prev().addClass('radio-selected')
    @view.render()
    sinon.stub(@model, 'requestUpdateProfile').returns TestUtils.promises.rejected
    errorStub = sinon.stub(@view, 'doCompleteRegisterError')
    @view.$('#wbi-complete-register-btn').click()
    expect(errorStub).to.be.calledOnce
    expect(@view.$ '#wbi-complete-register-btn').to.has.prop 'disabled', no

  it 'error is shown if request fail', ->
    @view.$('#wbi-birthdate-day').val registerBirthdayDay
    @view.$('#wbi-birthdate-month').val registerBirthdayMonth
    @view.$('#wbi-birthdate-year').val registerBirthdayYear
    @view.$('#wbi-complete-register-zipCode').val registerZipCode
    @view.$('.wbc-gender-male').prev().addClass('radio-selected')
    @view.render()
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
    @view.$('#wbi-birthdate-day').val registerBirthdayDay
    @view.$('#wbi-birthdate-month').val registerBirthdayMonth
    @view.$('#wbi-birthdate-year').val registerBirthdayYear
    @view.$('#wbi-complete-register-zipCode').val registerZipCode
    @view.$('.wbc-gender-male').prev().addClass('radio-selected')
    @view.render()
    sinon.stub(@model, 'requestUpdateProfile').returns TestUtils.promises.resolved
    successStub = sinon.stub(@view, 'doCompleteRegisterSuccess')
    @view.$('#wbi-complete-register-btn').click()
    expect(successStub).to.be.calledOnce
    expect(@view.$ '.error').to.not.exist

'use strict'

PersonalDataView = require 'views/personal-data/personal-data-view'
MyProfile = require 'models/my-profile/my-profile'
utils = require 'lib/utils'
$ = Winbits.$
_ = Winbits._
mediator = Winbits.Chaplin.mediator

describe 'PersonalDataViewSpec', ->

  before ->
    $.validator.setDefaults({ ignore: [] });

  after ->
    $.validator.setDefaults({ ignore: ':hidden' });

  beforeEach ->
    @loginData =
      apiToken: 'XXX'
      profile: { name: 'Jorge', lastName:"Moreno", gender:'male', phone:'0431256789', birthdate:'1988-11-11'}
      email: 'a@aa.aa'
    mediator.data.set 'login-data', @loginData
    @model = new MyProfile @loginData
    @view = new PersonalDataView model: @model
    @view.attach()

  afterEach ->
    utils.ajaxRequest.restore?()
    @view.dispose()
    @model.dispose()

  it 'personal data renderized', ->
    expect(@view.$ '#wbi-personal-data-form').to.exist

  it 'should render profile form data with data', ->
    personalData = name: 'Jorge', lastName:"Moreno", phone:'431256789'
    @view.model.set personalData
    _.each personalData, (value, key) ->
      expect(@view.$ "[name=#{key}]").to.has.value value
    , @

  it 'should render gender', ->
    @view.model.set gender: 'male'
    expect(@view.$ '[name=gender][value=H]').to.be.wbRadioChecked
    expect(@view.$ '[name=gender][value=M]').to.be.wbRadioUnchecked

    @view.model.set gender: 'female'
    expect(@view.$ '[name=gender][value=M]').to.be.wbRadioChecked
    expect(@view.$ '[name=gender][value=H]').to.be.wbRadioUnchecked

  it 'do request should succed to update profile', ->
    sinon.stub(@model, 'requestUpdateProfile').returns TestUtils.promises.resolved
    successStub = sinon.stub(@view, 'doUpdateProfileSuccess')
    @view.$('#wbi-update-profile-btn').click()
    expect(successStub).to.be.calledOnce
    expect(@view.$ '.error').to.not.exist

  it 'do not makes request if form invalid', ->
    ajaxRequestStub = sinon.stub(@view, 'doUpdateProfileError')
    @view.$('[name=name]').val('')
    @view.$('#wbi-update-profile-btn').click()
    expect(ajaxRequestStub).to.not.be.called

  it 'show validation errors if form invalid', ->
    @view.$('[name=name]').val('')
    @view.$('#wbi-update-profile-btn').click()
    expect(@view.$ '.error').to.exist

  it 'error is shown if api return error', ->
    sinon.stub(@model, 'requestUpdateProfile').returns TestUtils.promises.rejected
    errorStub = sinon.stub(@view, 'doUpdateProfileError')
    @view.$('#wbi-update-profile-btn').click()

    expect(errorStub).to.be.calledOnce
    expect(@view.$ '#wbi-update-profile-btn').to.has.prop 'disabled', no

  it 'error is shown if request fail', ->
    xhr = responseText: 'Server error'
    sinon.stub(@model, 'requestUpdateProfile').returns TestUtils.promises.rejected
    errorStub = sinon.stub(@view, 'doUpdateProfileError')
    @view.$('#wbi-update-profile-btn').click()

    expect(errorStub).to.be.calledOnce
    expect(@view.$ '#wbi-update-profile-btn').to.has.prop 'disabled', no



  it 'show validation errors if day is invalid', ->
    @view.$('#wbi-birthdate-day').val('58')
    @view.$('#wbi-birthdate-month').val('02')
    @view.$('#wbi-birthdate-year').val('02')
    @view.$('#wbi-update-profile-btn').click()
    expect(@view.$ '.error').to.exist

  it 'show validation errors if month is invalid', ->
    @view.$('#wbi-birthdate-day').val('08')
    @view.$('#wbi-birthdate-month').val('15')
    @view.$('#wbi-birthdate-year').val('02')
    @view.$('#wbi-update-profile-btn').click()
    expect(@view.$ '.error').to.exist

  it 'no show validation errors if date is valid', ->
    @view.$('#wbi-birthdate-day').val('18')
    @view.$('#wbi-birthdate-month').val('02')
    @view.$('#wbi-birthdate-year').val('02')
    sinon.stub(@model, 'requestUpdateProfile').returns TestUtils.promises.resolved
    successStub = sinon.stub(@view, 'doUpdateProfileSuccess')
    @view.$('#wbi-update-profile-btn').click()
    expect(successStub).to.be.calledOnce
    expect(@view.$ '.error').to.not.exist


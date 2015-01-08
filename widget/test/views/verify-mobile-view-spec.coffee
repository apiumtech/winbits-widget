'use strict'
verifyMobileView = require 'views/verify-mobile/verify-mobile-view'
verifyMobileModel = require 'models/verify-mobile/verify-mobile'
utils = require 'lib/utils'

describe 'VerifyModalViewSpec', ->

  before ->
    $.validator.setDefaults ignore: []

  after ->
    $.validator.setDefaults ignore: ':hidden'

  beforeEach ->
    @model = new verifyMobileModel
    @view = new verifyMobileView model: @model

  afterEach ->
    @model.dispose()
    @view.dispose()

  it 'verify mobile will be renderized', ->
    expect(@view.$('#wbi-ask-cell-input')).to.exist
    expect(@view.$('#wbi-resend-label')).to.exist
    expect(@view.$('#wbi-resend-label2')).to.exist
    expect(@view.$('#wbi-validate-button')).to.exist

  it 'When click on validar button and input is empty, sendCodeForActivationMobile function must not be called', ->
    validateCodebtnFunction = sinon.stub(@model,'sendCodeForActivationMobile')
    @view.$('#wbi-validate-button').click()
    expect(validateCodebtnFunction).not.called

  it 'When click on validar button and input has less than 5 characteres, sendCodeForActivationMobile function must not be called ',->
    @view.$('[name=code]').val('hola')
    validateCodebtnFunction = sinon.stub(@model,'sendCodeForActivationMobile')
    @view.$('#wbi-validate-button').click()
    expect(validateCodebtnFunction).not.called

  it 'When click on validar button and input has more than 5 characteres, sendCodeForActivationMobile function must not be called ',->
    @view.$('[name=code]').val('hola76')
    validateCodebtnFunction = sinon.stub(@model,'sendCodeForActivationMobile')
    @view.$('#wbi-validate-button').click()
    expect(validateCodebtnFunction).not.called

  it 'When click on validar button and input has 5 characteres, sendCodeForActivationMobile function must be called ',->
    @view.$('[name=code]').val('hol76')
    sinon.stub(@model,'sendCodeForActivationMobile').returns TestUtils.promises.resolved
    successStub = sinon.stub(@view, 'sendSuccess')
    @view.$('#wbi-validate-button').click()
    expect(successStub).to.be.calledOnce

  it.skip 'When click on validar button and there is an error, sendError function must be called', ->
    @view.$('[name=code]').val('hol76')
    sinon.stub(@model, 'sendCodeForActivationMobile').returns TestUtils.promises.rejected
    errorStub = sinon.stub(@view, 'sendError')
    @view.$('#wbi-validate-button').click()
    expect(errorStub).to.be.calledOnce

  it.skip 'When click on resend label, reSendSuccess function must be called ',->
    sinon.stub(@model,'reSendCodeToClient').returns TestUtils.promises.resolved
    successStub = sinon.stub(@view, 'reSendSuccess')
    @view.$('#wbi-resend-label').click()
    expect(successStub).to.be.calledOnce

  it.skip 'When click on resend label, reSendCodeToClient function must be called ',->
    sinon.stub(@model,'reSendCodeToClient').returns TestUtils.promises.rejected
    errorStub = sinon.stub(@view, 'reSendError')
    @view.$('#wbi-resend-label').click()
    expect(errorStub).to.be.calledOnce

  it.skip 'When click on resend label, reSendSuccess function must be called ',->
    sinon.stub(@model,'reSendCodeToClient').returns TestUtils.promises.resolved
    successStub = sinon.stub(@view, 'reSendSuccess')
    @view.$('#wbi-resend-label2').click()
    expect(successStub).to.be.calledOnce

  it.skip 'When click on resend label, reSendCodeToClient function must be called ',->
    sinon.stub(@model,'reSendCodeToClient').returns TestUtils.promises.rejected
    errorStub = sinon.stub(@view, 'reSendError')
    @view.$('#wbi-resend-label2').click()
    expect(errorStub).to.be.calledOnce
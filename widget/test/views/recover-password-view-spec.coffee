RecoverPasswordView = require 'views/recover-password/recover-password-view'
RecoverPasswordModel = require 'models/recover-password/recover-password'
utils =  require 'lib/utils'
$ = Winbits.$
email = 'test@winbits.com'

describe 'RecoverPasswordViewSpec', ->
  'use strict'

  before ->
    $.validator.setDefaults({ ignore: [] });

  after ->
    $.validator.setDefaults({ ignore: ':hidden' });

  beforeEach ->
    currentVertical = id: 1, baseUrl: 'http://www.test-winbits.com', name: 'Winbits Test'
    sinon.stub(Winbits.env, 'get')
      .withArgs('current-vertical-id').returns(currentVertical.id)
      .withArgs('current-vertical').returns(currentVertical)
      .withArgs('verticals-data').returns([
        currentVertical,
        { id: 2, baseUrl: 'http://dev.mylooq.com', name: 'My LOOQ' }
    ])
    @model = new RecoverPasswordModel
    @recoverPasswordView = new RecoverPasswordView model: @model, autoAttach: false
    sinon.stub(@recoverPasswordView, 'showAsModal')
    @recoverPasswordView.attach()
    @recoverPasswordView.$('[name=email]').val email

  afterEach ->
    @recoverPasswordView.showAsModal.restore?()
    utils.ajaxRequest.restore?()
    Winbits.env.get.restore?()

    @recoverPasswordView.dispose()

  it 'recover password view rendered',  ->
    expect(@recoverPasswordView.$el).has.id('wbi-recover-password-modal')
    expect(@recoverPasswordView.$('.wbc-recover-password-form')).is.rendered
    expect(@recoverPasswordView.$('input#wbi-recover-password-email')).to.exist
    expect(@recoverPasswordView.$('input#wbi-recover-password-btn')).to.exist
    .and.to.has.class('btn').and.to.has.value('Enviar')

  it 'send mail with correct email', ->
    sinon.stub(@model, 'requestRecoverPassword').returns TestUtils.promises.resolved
    successStub = sinon.stub(@recoverPasswordView, 'doRecoverPasswordSuccess')
    @recoverPasswordView.$('input#wbi-recover-password-btn').submit()

    expect(successStub).to.be.calledOnce
    expect(@recoverPasswordView.$('#wbi-recover-password-btn')).to.has.prop 'disabled', no

  it 'does not send mail with incorrect email', ->
    @recoverPasswordView.$('[name=email]').val('')
    successStub = sinon.stub(@recoverPasswordView, 'doRecoverPasswordSuccess')
    errorStub = sinon.stub(@recoverPasswordView, 'doRecoverPasswordError')
    @recoverPasswordView.$('input#wbi-recover-password-btn').submit()

    expect(successStub).to.not.be.called
    expect(errorStub).to.not.be.called

  it 'does not sent mail with error in api', ->
    sinon.stub(@model, 'requestRecoverPassword').returns TestUtils.promises.rejected
    errorStub = sinon.stub(@recoverPasswordView, 'doRecoverPasswordError')
    @recoverPasswordView.$('input#wbi-recover-password-btn').submit()

    expect(errorStub).to.be.calledOnce
    expect(@recoverPasswordView.$('#wbi-recover-password-btn')).to.has.prop 'disabled', no





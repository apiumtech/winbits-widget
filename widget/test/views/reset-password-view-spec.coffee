ResetPasswordView = require 'views/reset-password/reset-password-view'
ResetPasswordModel = require 'models/reset-password/reset-password'
utils =  require 'lib/utils'
$ = Winbits.$
password = '123456'
passwordConfirm = '123456'
mediator = Winbits.Chaplin.mediator

describe 'ResetPasswordViewSpec', ->
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
    @model = new ResetPasswordModel
    @resetPasswordView = new ResetPasswordView model: @model, autoAttach: false
    sinon.stub(@resetPasswordView, 'showAsModal')
    @resetPasswordView.attach()
    @resetPasswordView.$('[name=password]').val password
    @resetPasswordView.$('[name=passwordConfirm]').val passwordConfirm

  afterEach ->
    @resetPasswordView.showAsModal.restore?()
    utils.ajaxRequest.restore?()
    Winbits.env.get.restore?()

    @resetPasswordView.dispose()

  it 'reset password view rendered',  ->
    expect(@resetPasswordView.$el).has.id('wbi-reset-password-modal')
    expect(@resetPasswordView.$('.wbc-reset-password-form')).is.rendered
    expect(@resetPasswordView.$('input#wbi-reset-password')).to.exist
    expect(@resetPasswordView.$('input#wbi-reset-password-confirm')).to.exist
    expect(@resetPasswordView.$('input#wbi-reset-password-btn')).to.exist
    .and.to.has.class('btn').and.to.has.value('Enviar')
    expect(@resetPasswordView.$('.errorDiv')).to.exist.and.is.hide

  it 'change password correctly', ->
    mediator.data.set('salt',{salt: 'f9q8d256_1asd6r87ewr54f+qew7r982asdf5749q'})
    sinon.stub(@model, 'requestResetPassword').returns TestUtils.promises.resolved
    successStub = sinon.stub(@resetPasswordView, 'doResetPasswordSuccess')
    @resetPasswordView.$('input#wbi-reset-password-btn').click()
    expect(successStub).to.be.calledOnce
    expect(@resetPasswordView.$('#wbi-reset-password-btn')).to.has.prop 'disabled', no
    mediator.data.set('salt',{})

  it 'does not change password for validate', ->
    @resetPasswordView.$('[name=passwordConfirm]').val '654321'
    successStub = sinon.stub(@resetPasswordView, 'doResetPasswordSuccess')
    requestReset = sinon.stub(@model, 'requestResetPassword').returns TestUtils.promises.resolved
    errorStub = sinon.stub(@resetPasswordView, 'doResetPasswordError')
    @resetPasswordView.$('input#wbi-reset-password-btn').click()

    expect(successStub).to.not.be.called
    expect(requestReset).to.not.be.called
    expect(errorStub).to.not.be.called

  it 'does not change password with error in api', ->
    sinon.stub(@model, 'requestResetPassword').returns TestUtils.promises.rejected
    errorStub = sinon.stub(@resetPasswordView, 'doResetPasswordError')
    @resetPasswordView.$('input#wbi-reset-password-btn').click()

    expect(errorStub).to.be.calledOnce
    expect(@resetPasswordView.$('#wbi-reset-password-btn')).to.has.prop 'disabled', no
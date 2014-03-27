LoginView = require 'views/login/login-view'
utils = require 'lib/utils'
$ = Winbits.$

describe 'Should do login', ->
    beforeEach ->
        @view = new LoginView autoAttach: false
        # sinon.spy($,"ajax")
        sinon.stub(@view, 'showAsModal')
        @view.attach()
        sinon.stub(utils, 'serializeForm').returns(email: 'x@y', password: 'xxx', rememberMe: 'rememberMe')

    afterEach ->
        # $.ajax.restore()
        @view.showAsModal.restore()
        utils.serializeForm.restore()
        @view.dispose()

    it 'login view renderized', ->
        expect(@view.$el).has.id('wbi-login-modal')
                .and.has.class('wbc-hide')
        expect(@view.$ '#wbi-login-form').is.rendered

    it 'do login should succed to Login', ->
        sinon.stub(utils, 'validateForm').returns(true)
        sinon.stub(utils, 'ajaxRequest').yieldsTo('success', {})
        successStub = sinon.stub(@view, 'doLoginSuccess')
        @view.$('#wbi-login-in-btn').click()

        successStub.calledOnce

        utils.validateForm.restore()
        utils.ajaxRequest.restore()

    # it 'do login with incomplete form', ->
    #     util.validateForm = sinon.stub().returns(false)
    #     event = sinon.stub()
    #     expect(@view.doLogin(event)).to.equal 'Fail to login 1'

    # it 'do login should throws an error to Login', ->
    #     util.validateForm = sinon.stub().returns(true)
    #     util.ajaxRequest = sinon.stub().returns('error')
    #     event = sinon.stub()
    #     response = @view.doLogin(event)
    #     expect(response).to.equal 'error'

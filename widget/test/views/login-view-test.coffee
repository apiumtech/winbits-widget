LoginView = require 'views/login/login-view'
utils = require 'lib/utils'
$ = Winbits.$

describe 'Should do login', ->
    beforeEach ->
        @view = new LoginView autoAttach: false
        # sinon.spy($,"ajax")
        sinon.stub(@view, 'showAsModal')
        @view.attach()

    afterEach ->
        # $.ajax.restore()
        @view.showAsModal.restore()
        @view.dispose()

    it 'login view renderized', ->
        expect(@view.$el).has.id('wbi-login-modal')
                .and.has.class('wbc-hide')

    it 'do login should succed to Login', ->
        util.validateForm = sinon.stub().returns(true)
        util.ajaxRequest = sinon.stub().returns('success')
        event = sinon.stub()
        response = @view.doLogin(event)
        expect(response).to.equal 'success'

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

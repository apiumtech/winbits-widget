'use strict'
NotLoggedInView =  require 'views/not-logged-in/not-logged-in-view'
NotLoggedIn =  require 'models/not-logged-in/not-logged-in'
utils = require 'lib/utils'
loginUtils = require 'lib/login-utils'
$ = Winbits.$
rpc = Winbits.env.get('rpc')

describe 'RememberCompleteRegisterInFacebookLoginSpec', ->

  LOGIN_FACEBOOK_RESPONSE = '{"meta":{"status":200},"response":{"id":6,"email":"test@test.com","apiToken":"B2zvcTmPIKaRbigIPTlitmGJ9rpeF6slAGqvwI5n9PWm2HGZWjnk5UnmzXWVf8wq","bitsBalance":100,"profile":{"name":"Emmanuel","lastName":"Maldonado","birthdate":"1988-05-11","gender":"male","zipCodeInfo":{"id":1,"locationName":"Location","locationCode":"1","locationType":"1","county":"San Carlos","city":"Mexico","state":"Edo. Mex","zipCode":"11111"},"zipCode":"11111","location":"Location","phone":"5557871374","newsletterPeriodicity":"weekly","newsletterFormat":"unified","wishListCount":0,"waitingListCount":0,"pendingOrdersCount":0},"socialAccounts":[{"name":"Facebook","providerId":"facebook","logo":"facebook.png","available":true},{"name":"Twitter","providerId":"twitter","logo":"twitter.png","available":false}],"subscriptions":[{"id":2,"name":"My Looq","active":false},{"id":3,"name":"Panda Sports","active":false},{"id":4,"name":"clickOnero","active":false}],"mainShippingAddres":null,"loginRedirectUrl":"http://localhost/widgets/logout.html","cashbackForComplete":100,"showRemainder":true}}'
  LOGIN_FACEBOOK_RESPONSE_FALSE = '{"meta":{"status":200},"response":{"id":6,"email":"test@test.com","apiToken":"B2zvcTmPIKaRbigIPTlitmGJ9rpeF6slAGqvwI5n9PWm2HGZWjnk5UnmzXWVf8wq","bitsBalance":100,"profile":{"name":"Emmanuel","lastName":"Maldonado","birthdate":"1988-05-11","gender":"male","zipCodeInfo":{"id":1,"locationName":"Location","locationCode":"1","locationType":"1","county":"San Carlos","city":"Mexico","state":"Edo. Mex","zipCode":"11111"},"zipCode":"11111","location":"Location","phone":"5557871374","newsletterPeriodicity":"weekly","newsletterFormat":"unified","wishListCount":0,"waitingListCount":0,"pendingOrdersCount":0},"socialAccounts":[{"name":"Facebook","providerId":"facebook","logo":"facebook.png","available":true},{"name":"Twitter","providerId":"twitter","logo":"twitter.png","available":false}],"subscriptions":[{"id":2,"name":"My Looq","active":false},{"id":3,"name":"Panda Sports","active":false},{"id":4,"name":"clickOnero","active":false}],"mainShippingAddres":null,"loginRedirectUrl":"http://localhost/widgets/logout.html","cashbackForComplete":100,"showRemainder":false}}'

  beforeEach ->
    @server = sinon.fakeServer.create()
    @clock = sinon.useFakeTimers()

    currentVertical = id: 1, baseUrl: 'http://www.test-winbits.com', name: 'Winbits Test'
    sinon.stub($.fancybox, "close")
    sinon.stub(loginUtils, "applyLogin")
    sinon.stub(utils, "redirectToLoggedInHome")

    @envStub = sinon.stub(Winbits.env, 'get')
    .withArgs('current-vertical-id').returns(currentVertical.id)
    .withArgs('api-url').returns('https://apidev.winbits.com/v1')
    .withArgs('current-vertical').returns(currentVertical)
    .withArgs('rpc').returns(rpc)
    .withArgs('verticals-data').returns([
      currentVertical
    { id: 2, baseUrl: 'http://dev.mylooq.com', name: 'My LOOQ' }
    ])

    @windowsOpenStub = sinon.stub(window, 'open').returns(focus: $.noop, closed:yes)
    @view = new NotLoggedInView
    @model = @view.model

  afterEach ->
    @server.restore()
    @clock.restore()
    loginUtils.applyLogin.restore?()
    utils.redirectToLoggedInHome.restore?()
    Winbits.env.get.restore()
    window.open.restore()

    rpc.facebookStatus.restore?()
    utils.redirectTo.restore?()
    @view.facebookLoginInterval.restore?()
    @view.doFacebookLoginSuccess.restore?()
    @view.doFacebookLoginError.restore?()
    @model.requestExpressFacebookLogin.restore?()
    $.fancybox.close.restore?()
    utils.showConfirmationModal.restore()

    @model.dispose()
    @view.dispose()

  it 'should view remember complete register in success authentication facebook', ->
    utilsShowConfirmationCompleteRegister = sinon.stub(utils,'showConfirmationModal')
    sinon.stub(rpc, 'facebookStatus', (callback)->
      callback (status:'connected', authResponse:{userID:'100002184900102'})
    )
    @view.publishEvent 'facebook-button-event'
    @clock.tick(150)
    @server.requests[0].respond(200, { "Content-Type": "application/json" }, LOGIN_FACEBOOK_RESPONSE)
    expect(utilsShowConfirmationCompleteRegister).to.be.called


  it 'should NOT view remember complete register in success authentication facebook', ->
    utilsShowConfirmationCompleteRegister = sinon.stub(utils,'showConfirmationModal')
    sinon.stub(rpc, 'facebookStatus', (callback)->
      callback (status:'connected', authResponse:{userID:'100002184900102'})
    )
    @view.publishEvent 'facebook-button-event'
    @clock.tick(150)
    @server.requests[0].respond(200, { "Content-Type": "application/json" }, LOGIN_FACEBOOK_RESPONSE_FALSE)
    expect(utilsShowConfirmationCompleteRegister).to.not.be.called
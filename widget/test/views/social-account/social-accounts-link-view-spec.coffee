'use strict'
SocialAccountsView = require 'views/social-accounts/social-accounts-view'
SocialAccounts = require 'models/social-accounts/social-accounts'
utils = require 'lib/utils'
$ = Winbits.$
mediator = Winbits.Chaplin.mediator
rpc = Winbits.env.get('rpc')

describe 'SocialAccountsLinkViewSpec', ->

  FACEBOOK_URL = utils.getResourceURL('users/connect/facebook.json')
  TWITTER_URL = utils.getResourceURL('users/connect/twitter.json')
  TWITTER_RESPONSE = '{"meta":{"status":200},"response":{"socialUrl":"https://api.twitter.com/oauth/authorize?oauth_token=12jWNYjnjY8TAQpQTA7tOOYvFHdv27JHBUBEsjXGtA"}}'
  FACEBOOK_RESPONSE = '{"meta":{"status":200},"response":{"socialUrl":"https://graph.facebook.com/oauth/authorize?client_id=486640894740634&response_type=code&redirect_uri=https%3A%2F%2Fapidev.winbits.com%2Fv1%2Fusers%2Fconnect%2Ffacebook%3Fuser%3Dyou_fhater%2540hotmail.com&scope=publish_actions,publish_stream,share_item"}}'

  beforeEach ->
    @data = sinon.useFakeXMLHttpRequest()
    requests = @requests = []
    @data.onCreate = (data) -> requests.push(data)

    @model = new SocialAccounts
    @view = new SocialAccountsView model: @model

  afterEach ->
    @data.restore()
    @view.dispose()
    @model.dispose()
    utils.showConfirmationModal.restore?()
    utils.ajaxRequest.restore?()
#    favoriteUtils.publishWishListChangeEvent.restore?()
#    favoriteUtils.showWishListErrorMessage.restore?()

  it "Should be called modal render", ->
    sinon.stub(@view,'doLinkTwitter')
    request = @requests[0]
    request.respond(200, { "Content-Type": "application/json" }, TWITTER_URL)
    sinon.stub(@view, 'successConnectTwitterLink')
    @view.$('a.wbc-twitter-link').click()
    expect(@view.successConnectTwitterLink).to.be.calledOnce


  it "Should delete brand from wish list", ->
    sinon.stub(utils, 'ajaxRequest').returns TestUtils.promises.resolved
    successStub = sinon.stub(favoriteUtils, 'publishWishListChangeEvent')
    errorStub = sinon.stub(favoriteUtils, 'showWishListErrorMessage')
    @view.doRequestDeleteBrand('1')
    expect(successStub).to.be.calledOnce
    expect(errorStub).to.not.be.calledOnce

  it "Should no delete brand from wish list with error in api", ->
    sinon.stub(utils, 'ajaxRequest').returns TestUtils.promises.rejected
    successStub = sinon.stub(favoriteUtils, 'publishWishListChangeEvent')
    errorStub = sinon.stub(favoriteUtils, 'showWishListErrorMessage')
    @view.doRequestDeleteBrand('1')
    expect(successStub).to.not.be.calledOnce
    expect(errorStub).to.be.calledOnce

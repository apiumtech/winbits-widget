'use strict'
socialUtils = require 'lib/social-utils'
utils = require 'lib/utils'
$ = Winbits.$
mediator = Winbits.Chaplin.mediator

describe 'social-utils', ->

  FACEBOOK_SHARE_URL = utils.getResourceURL('social/announcement/facebook/promoteProduct')
  FACEBOOK_LIKE_URL = utils.getResourceURL('users/facebookPublish/like.json')
  TWITTER_TWEET_URL = utils.getResourceURL('users/twitterPublish/updateStatus.json')
  FACEBOOK_SHARE_SUCCESS_RESPONSE = '{"meta":{"status":200},"response":{"objectId":"1310-132031830"}}'

  before ->
    sinon.stub(utils, 'isLoggedIn').returns(yes)
    sinon.stub(utils, 'getApiToken').returns(undefined)


  after ->
    utils.getApiToken.restore()
    utils.isLoggedIn.restore()

  beforeEach ->
    @loginData =
      id: 19
      apiToken: '6ue7zrBfNkxgNTvT4ReGpuh55yjNLRl6qEHiXMFyXFx6M3ymV21EaARwilDZK0zM'
      bitsBalance: 0
      socialAccounts:[{name:'Facebook',available:'true'},{name:'Twitter', available:'True'}]
    mediator.data.set 'login-data', @loginData
    @xhr = sinon.useFakeXMLHttpRequest()
    requests = @requests = []
    @xhr.onCreate = (xhr) -> requests.push(xhr)
    sinon.spy(utils, 'ajaxRequest')

  afterEach ->
    @xhr.restore()
    utils.ajaxRequest.restore()
    socialUtils.socialUtilsSuccess.restore?()

  it 'should request to share Facebook', ->
    promise = socialUtils.share({ name:'test Winbits', message:' pinchis monos !! @deathtux @diegoazd lol', 'linkUrl':'http://twitter.com', imageUrl:'https://fbcdn-sphotos-h-a.akamaihd.net/hphotos-ak-xpf1/t1.0-9/1466064_625150900863769_1297499413_n.jpg','caption':'caption','description':'description'})
    expect(promise).to.be.promise

    request = @requests[0]
    expect(request.url).to.be.equal(FACEBOOK_SHARE_URL)
    expect(request.method).to.be.equal('POST')
    expect(request.async).to.be.true
    expect(request.requestHeaders).to.has.property('Content-Type')

  it 'should request to like Facebook', ->
    promise = socialUtils.like({ id:'100001010101-100011'})
    expect(promise).to.be.promise

    request = @requests[0]
    expect(request.url).to.be.equal(FACEBOOK_LIKE_URL)
    expect(request.method).to.be.equal('POST')
    expect(request.async).to.be.true
    expect(request.requestHeaders).to.has.property('Content-Type')

  it 'should request to tweet Twitter', ->
    promise = socialUtils.tweet({ message:' pinchis monos !! @deathtux @diegoazd lol'})
    expect(promise).to.be.promise

    request = @requests[0]
    expect(request.url).to.be.equal(TWITTER_TWEET_URL)
    expect(request.method).to.be.equal('POST')
    expect(request.async).to.be.true
    expect(request.requestHeaders).to.has.property('Content-Type')

  it 'should request Facebook share response success', ->
    sinon.stub socialUtils, 'socialUtilsSuccess'
    socialUtils.share({ name:'test Winbits', message:' pinchis monos !! @deathtux @diegoazd lol', 'linkUrl':'http://twitter.com', imageUrl:'https://fbcdn-sphotos-h-a.akamaihd.net/hphotos-ak-xpf1/t1.0-9/1466064_625150900863769_1297499413_n.jpg','caption':'caption','description':'description'})
    respondSuccess.call(@, FACEBOOK_SHARE_SUCCESS_RESPONSE)
    expect(socialUtils.socialUtilsSuccess).to.have.been.calledOnce

  it 'should request Facebook like response success', ->
    sinon.stub socialUtils, 'socialUtilsSuccess'
    socialUtils.like({ id:'100001010101-100011'})
    respondSuccess.call(@, "{}")
    expect(socialUtils.socialUtilsSuccess).to.have.been.calledOnce

  it 'should request Twitter tweet response success', ->
    sinon.stub socialUtils, 'socialUtilsSuccess'
    socialUtils.tweet({ message:' pinchis monos !! @deathtux @diegoazd lol'})
    respondSuccess.call(@, "{}")
    expect(socialUtils.socialUtilsSuccess).to.have.been.calledOnce

  respondSuccess = (obj) ->
    request = @requests[0]
    request.respond(200, { "Content-Type": "application/json" }, obj)

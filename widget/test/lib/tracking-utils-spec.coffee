'use strict'

utils = require 'lib/utils'
trackingUtils = require 'lib/tracking-utils'
_ = Winbits._
rpc = Winbits.env.get('rpc')
mediator = Chaplin.mediator

describe 'TrackingUtilsSpec', ->

  beforeEach ->
    sinon.stub(trackingUtils, 'getURLParams')
    sinon.stub(rpc, 'storeUTMs')
    sinon.stub(utils, 'isLoggedIn')

  afterEach ->
    rpc.storeUTMs.restore()
    utils.isLoggedIn.restore()
    trackingUtils.getURLParams.restore()
    trackingUtils.URL_CONTAINS_VALID_UTMS = no

  it "parseUTMParams filter out params which do not start with 'utm_'", ->
    trackingUtils.getURLParams.returns(
      utm_content: 'content'
      xxx: 'xxx'
      utm_source: 'source'
    )

    expect(trackingUtils.parseUTMParams()).to.be.deep.equal(
      content: 'content'
      source: 'source'
    )

  it "validateUTMParams check for valid utms", ->
    utms = getValidUTMs()
    expect(trackingUtils.validateUTMParams(utms)).to.be.true

  _.each [
    null
    undefined
    {}
    { campaign: 'campaign', other: 'x' }
    { medium: 'medium', other: 'x' }
  ], (utms) ->
    utmsDesc = if utms then JSON.stringify(utms) else utms
    it "validateUTMParams check for invalid utms: #{utmsDesc}", ->
      expect(trackingUtils.validateUTMParams(utms)).to.be.false

  it "saveUTMsIfNeeded saves UTMs", sinon.test ->
    utms = getValidUTMs()
    @stub(trackingUtils, 'getUTMParams').returns(utms)
    @stub(trackingUtils, 'shouldSaveUTMs').returns(yes)

    trackingUtils.saveUTMsIfNeeded()

    expect(rpc.storeUTMs).to.has.been.calledWith(utms)
      .and.to.has.been.calledOnce

  it "saveUTMsIfNeeded does not save UTMs", sinon.test ->
    @stub(trackingUtils, 'getUTMs')
    @stub(trackingUtils, 'shouldSaveUTMs').returns(no)

    trackingUtils.saveUTMsIfNeeded()
    expect(rpc.storeUTMs).to.has.not.been.called

  it "shouldSaveUTMs returns yes", ->
    trackingUtils.URL_CONTAINS_VALID_UTMS = yes
    utils.isLoggedIn.returns(no)
    expect(trackingUtils.shouldSaveUTMs()).to.be.true

  _.each [
    {utmParams: no, loggedIn: no}
    {utmParams: no, loggedIn: yes}
    {utmParams: yes, loggedIn: yes}
  ], (flags) ->
    it "shouldSaveUTMs returns no when: #{flags}", ->
      trackingUtils.URL_CONTAINS_VALID_UTMS = flags.utmParams
      utils.isLoggedIn.returns(flags.loggedIn)
      expect(trackingUtils.shouldSaveUTMs()).to.be.false

  getValidUTMs = ->
    campaign: 'campaign'
    medium: 'medium'

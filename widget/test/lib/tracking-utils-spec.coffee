'use strict'

trackingUtils = require 'lib/tracking-utils'
utils = require 'lib/utils'
_ = Winbits._
rpc = Winbits.env.get('rpc')
mediator = Chaplin.mediator

describe 'TrackingUtilsSpec', ->

  beforeEach ->
    sinon.stub(utils, 'getUrlParams')
    mediator.data.set('utms', undefined)

  afterEach ->
    utils.getUrlParams.restore()

  it "getUtmParams filter out params which do not start with 'utm_'", ->
    utils.getUrlParams.returns(
      utm_content: 'content'
      xxx: 'xxx'
      utm_source: 'source'
    )

    expect(trackingUtils.getUtmParams()).to.be.deep.equal(
      utm_content: 'content'
      utm_source: 'source'
    )

  it "validateUtmParams check for valid utms", ->
    utms = getValidUtmParams()

    expect(trackingUtils.validateUtmParams(utms)).to.be.true

  _.each [
    null
    undefined
    {}
    { utm_campaign: 'campaign', other: 'x' }
    { utm_medium: 'medium', other: 'x' }
  ], (utms) ->
    utmsDesc = if utms then JSON.stringify(utms) else utms
    it "validateUtmParams check for invalid utms: #{utmsDesc}", ->
      expect(trackingUtils.validateUtmParams(utms)).to.be.false

  it "saveUtmsIfAvailable saves UTMs on rpc if valid", sinon.test ->
    utms = getValidUtmParams()
    utms.other = 'x'
    utils.getUrlParams.returns(utms)
    @stub(rpc, 'saveUtms')

    trackingUtils.saveUtmsIfAvailable()

    expect(rpc.saveUtms).to.has.been.calledWithMatch(
      utm_campaign: 'campaign', utm_medium: 'medium'
    ).and.to.has.been.calledOnce
    expect()

  it "saveUtmsIfAvailable does not save UTMs on rpc if invalid", sinon.test ->
    utils.getUrlParams.returns({})
    @stub(rpc, 'saveUtms')

    trackingUtils.saveUtmsIfAvailable()

    expect(rpc.saveUtms).to.has.not.been.called

  getValidUtmParams = ->
    utm_campaign: 'campaign'
    utm_medium: 'medium'

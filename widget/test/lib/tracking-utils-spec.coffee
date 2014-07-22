'use strict'

trackingUtils = require 'lib/tracking-utils'
_ = Winbits._
rpc = Winbits.env.get('rpc')
mediator = Chaplin.mediator

describe 'TrackingUtilsSpec', ->

  beforeEach ->
    sinon.stub(trackingUtils, 'getURLParams')
    mediator.data.set('utms', undefined)

  afterEach ->
    trackingUtils.getURLParams.restore()

  it "getUTMParams filter out params which do not start with 'utm_'", ->
    trackingUtils.getURLParams.returns(
      utm_content: 'content'
      xxx: 'xxx'
      utm_source: 'source'
    )

    expect(trackingUtils.getUTMParams()).to.be.deep.equal(
      utm_content: 'content'
      utm_source: 'source'
    )

  it "validateUTMParams check for valid utms", ->
    utms = getValidUTMParams()

    expect(trackingUtils.validateUTMParams(utms)).to.be.true

  _.each [
    null
    undefined
    {}
    { utm_campaign: 'campaign', other: 'x' }
    { utm_medium: 'medium', other: 'x' }
  ], (utms) ->
    utmsDesc = if utms then JSON.stringify(utms) else utms
    it "validateUTMParams check for invalid utms: #{utmsDesc}", ->
      expect(trackingUtils.validateUTMParams(utms)).to.be.false

  it "saveUTMsIfAvailable saves UTMs if valid", sinon.test ->
    utms = getValidUTMParams()
    utms.other = 'x'
    trackingUtils.getURLParams.returns(utms)
    @stub(rpc, 'saveUTMs')

    utms = trackingUtils.saveUTMsIfAvailable()

    expectedUTMs = utm_campaign: 'campaign', utm_medium: 'medium'
    expect(utms).to.be.deep.equal(expectedUTMs)
    expect(rpc.saveUTMs).to.has.been.calledWith(utms)
      .and.to.has.been.calledOnce
    expect(mediator.data.get('utms')).to.be.equal(utms)

  it "saveUTMsIfAvailable does not save UTMs on rpc if invalid", sinon.test ->
    trackingUtils.getURLParams.returns({})
    @stub(rpc, 'saveUTMs')

    utms = trackingUtils.saveUTMsIfAvailable()
    expect(utms).to.not.be.ok
    expect(rpc.saveUTMs).to.has.not.been.called
    expect(mediator.data.get('utms')).to.not.be.ok

  getValidUTMParams = ->
    utm_campaign: 'campaign'
    utm_medium: 'medium'

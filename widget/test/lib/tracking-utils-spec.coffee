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

  it "getUTMParams filter out params which do not start with 'utm_'", ->
    utils.getUrlParams.returns(
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

  it "saveUTMsIfAvailable saves UTMs on rpc if valid", sinon.test ->
    utms = getValidUTMParams()
    utms.other = 'x'
    utils.getUrlParams.returns(utms)
    @stub(rpc, 'saveUTMs')

    trackingUtils.saveUTMsIfAvailable()

    expect(rpc.saveUTMs).to.has.been.calledWithMatch(
      utm_campaign: 'campaign', utm_medium: 'medium'
    ).and.to.has.been.calledOnce
    expect()

  it "saveUTMsIfAvailable does not save UTMs on rpc if invalid", sinon.test ->
    utils.getUrlParams.returns({})
    @stub(rpc, 'saveUTMs')

    trackingUtils.saveUTMsIfAvailable()

    expect(rpc.saveUTMs).to.has.not.been.called

  getValidUTMParams = ->
    utm_campaign: 'campaign'
    utm_medium: 'medium'

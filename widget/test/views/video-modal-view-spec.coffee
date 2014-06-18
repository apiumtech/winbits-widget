'use strict'
VideoModalView = require 'views/video-modal/video-modal-view'
utils =  require 'lib/utils'
$ = Winbits.$
email = 'test@winbits.com'
password = "1234567"

describe 'VideoModalViewSpec', ->

  before ->
    $.validator.setDefaults({ ignore: [] });

  after ->
    $.validator.setDefaults({ ignore: ':hidden' });

  beforeEach ->
    @view = new VideoModalView autoAttach: no
    sinon.stub(@view, 'showAsModal')
    @view.attach()

  afterEach ->
    @view.showAsModal.restore()
    @view.dispose()

  it 'video modal view rendered',  ->
    expect(@view.$el).has.id('wbi-video-modal-view')

  it 'video has iframe', ->
    expect(@view.$('#wbi-video-modal-container')).to.exist
    expect(@view.$('#wbi-iframe-video')).to.exist

testUtils = require 'test/lib/test-utils'
$ = Winbits.$
_ = Winbits._

describe 'jQueryWbPaginatorSpec', ->

  beforeEach ->
    @$el = $('<div></div>')

  afterEach ->

  it 'should be a jQuery plugin', ->
    expect($().wbpaginator).to.be.a('function')
    expect(@$el.wbpaginator()).to.be.equal(@$el)

  it 'should have default options', ->
    @$el.wbpaginator(total: 100)

    expect(@$el.wbpaginator('option', 'total')).to.be.equal(100)
    expect(@$el.wbpaginator('option', 'max')).to.be.equal(10)
    expect(@$el.wbpaginator('option', 'page')).to.be.equal(1)

  it 'should set all options', ->
    @$el.wbpaginator(total: 50, max: 5, page: 3)

    expect(@$el.wbpaginator('option', 'total')).to.be.equal(50)
    expect(@$el.wbpaginator('option', 'max')).to.be.equal(5)
    expect(@$el.wbpaginator('option', 'page')).to.be.equal(3)

  _.each [0, 'x'], (total) ->
    it "should not set invalid total value: #{total}", ->
      @$el.wbpaginator(total: total)

      expect(@$el.wbpaginator('option', 'total')).to.not.be.ok

  _.each [99.1, 99.5, 99.9], (total) ->
    it "should round total to next integer value: #{total}", ->
      @$el.wbpaginator(total: total)

      expect(@$el.wbpaginator('option', 'total')).to.be.equal(100)

  it 'should set default max if max greater than total', ->
    @$el.wbpaginator(total: 100, max: 200)

    expect(@$el.wbpaginator('option', 'max')).to.be.equal(10)

  _.each [0, 'x', 100.1], (max) ->
    it "should set default max if value invalid: #{max}", ->
      @$el.wbpaginator(total: 100, max: max)

      expect(@$el.wbpaginator('option', 'max')).to.be.equal(10)
  , @

  _.each [49.1, 49.5, 49.9], (max) ->
    it "should round max to next integer value: #{max}", ->
      @$el.wbpaginator(total: 100, max: max)

      expect(@$el.wbpaginator('option', 'max')).to.be.equal(50)
  , @

  _.each [0, 11, 'x', 10.1], (page) ->
    it "should set default page if value invalid: #{page}", ->
      @$el.wbpaginator(total: 100, page: page)

      expect(@$el.wbpaginator('option', 'page')).to.be.equal(1)
  , @

  _.each [9.1, 9.5, 9.9], (page) ->
    it "should round page to next integer value: #{page}", ->
      @$el.wbpaginator(total: 100, page: page)

      expect(@$el.wbpaginator('option', 'page')).to.be.equal(10)
  , @

  it 'should set default max if max greater than total', ->
    @$el.wbpaginator(total: 100, max: 200)

    expect(@$el.wbpaginator('option', 'max')).to.be.equal(10)

  it 'should generate pager text', ->
    @$el.wbpaginator(total: 100)

    $pager = @$el.find('p.wbc-pager-text')
    expect($pager).to.existExact(1)
    expect($pager).to.has.$text('Página 1 de 10')

  it 'should generate pages list', ->
    @$el.wbpaginator(total: 100)

    expect(@$el.find('ul.wbc-pagers')).to.existExact(1)

  it 'should generate previous pager', ->
    @$el.wbpaginator(total: 100)

    $previousPager = @$el.find('li.wbc-previous-pager')
    expect($previousPager).to.existExact(1)
    expect($previousPager).to.has.$class('pager-prev')

  it 'should generate previous pager as the first pager', ->
    @$el.wbpaginator(total: 100)

    $firstPager = @$el.find('ul.wbc-pagers').children().first()
    expect($firstPager).to.has.$class('wbc-previous-pager')

  it 'should generate previous pager link', ->
    @$el.wbpaginator(total: 100)

    $previousPagerLink = @$el.find('a.wbc-previous-pager-link')
    expect($previousPagerLink).to.existExact(1)
    expect($previousPagerLink.parent()).to.has.$class('wbc-previous-pager')
    expect($previousPagerLink).to.has.$text(' Ant')

  it 'should generate previous pager arrow', ->
    @$el.wbpaginator(total: 100)
    $arrowSpan = @$el.find('.wbc-previous-pager-link').children()
    expect($arrowSpan).to.has.$class('iconFont-arrowLeft')

  it 'should generate next pager', ->
    @$el.wbpaginator(total: 100)

    $nextPager = @$el.find('li.wbc-next-pager')
    expect($nextPager).to.existExact(1)
    expect($nextPager).to.has.$class('pager-next')

  it 'should generate next pager as the last pager', ->
    @$el.wbpaginator(total: 100)

    $firstPager = @$el.find('ul.wbc-pagers').children().last()
    expect($firstPager).to.has.$class('wbc-next-pager')

  it 'should generate next pager link', ->
    @$el.wbpaginator(total: 100)

    $nextPagerLink = @$el.find('a.wbc-next-pager-link')
    expect($nextPagerLink).to.existExact(1)
    expect($nextPagerLink.parent()).to.has.$class('wbc-next-pager')
    expect($nextPagerLink).to.has.$text('Sig ')

  it 'should generate next pager arrow', ->
    @$el.wbpaginator(total: 100)
    $arrowSpan = @$el.find('.wbc-next-pager-link').children()
    expect($arrowSpan).to.has.$class('iconFont-arrowRight')

  _.each [1, 5, 10], (totalPages) ->
    it "should generate exact pagers if total pages are 10 or less: #{totalPages}", ->
      max = 10
      @$el.wbpaginator(total: totalPages * max, max: 10)

      expect(@$el.find('li.wbc-pager').length).to.be.equal(totalPages)
      expect(@$el.find('a.wbc-pager-link').length).to.be.equal(totalPages)
  , @

  it 'should generate pagers', ->
    @$el.wbpaginator(total: 100)

    $pagers = @$el.find('li.wbc-pager')
    for page in [1, 10]
      $pager = $pagers.eq(page - 1)
      expect($pager).to.has.$text(page.toString())
      $pagerLink = $pager.find('a')
      expect($pagerLink.data('_id')).to.be.equal(page)

  it 'should render correct page option', ->
    @$el.wbpaginator(total: 100, page: 5)

    expect(@$el.find('.wbc-pager-text')).to.has.$text('Página 5 de 10')

  it 'should render correct total pages', ->
    @$el.wbpaginator(total: 53, max: 5)

    expect(@$el.find('.wbc-pager-text')).to.has.$text('Página 1 de 11')

  it 'should move to previous page if previous page link is clicked', ->
    @$el.wbpaginator(total: 100, page: 10)

    @$el.find('.wbc-previous-pager-link').click()
    expect(@$el.find('.wbc-pager-text')).to.has.$text('Página 9 de 10')

    expect(@$el.wbpaginator('option', 'page')).to.be.equal(9)

  it 'should trigger change event previous page link is clicked', ->
    stub = sinon.stub()
    @$el.wbpaginator(total: 100, page: 10, change: stub)

    @$el.find('.wbc-previous-pager-link').click()

    expect(stub).to.has.been.calledOnce
    expect(stub.firstCall.args[1]).to.be.eql(total: 100, max: 10, page: 9, offset: 80)

  it 'should not move the page if previous page link is clicked and current page is 1', ->
    @$el.wbpaginator(total: 100, page: 1)

    @$el.find('.wbc-previous-pager-link').click()

    expect(@$el.wbpaginator('option', 'page')).to.be.equal(1)
    expect(@$el.find('.wbc-pager-text')).to.has.$text('Página 1 de 10')

  it 'should not trigger change event if previous page link is clicked and current page is 1', ->
    stub = sinon.stub()
    @$el.wbpaginator(total: 100, page: 1, change: stub)

    @$el.find('.wbc-previous-pager-link').click()

    expect(stub).to.has.not.been.called

  it 'should move to next page if next page link is clicked', ->
    @$el.wbpaginator(total: 100, page: 1)

    @$el.find('.wbc-next-pager-link').click()

    expect(@$el.wbpaginator('option', 'page')).to.be.equal(2)
    expect(@$el.find('.wbc-pager-text')).to.has.$text('Página 2 de 10')

  it 'should trigger change event next page link is clicked', ->
    stub = sinon.stub()
    @$el.wbpaginator(total: 100, page: 1, change: stub)

    @$el.find('.wbc-next-pager-link').click()

    expect(stub).to.has.been.calledOnce
    expect(stub.firstCall.args[1]).to.be.eql(total: 100, max: 10, page: 2, offset: 10)

  it 'should not move the page if next page link is clicked and current page is the last possible page', ->
    @$el.wbpaginator(total: 100, page: 10)

    @$el.find('.wbc-next-pager-link').click()

    expect(@$el.wbpaginator('option', 'page')).to.be.equal(10)
    expect(@$el.find('.wbc-pager-text')).to.has.$text('Página 10 de 10')

  it 'should not trigger change event if next page link is clicked and current page is 1', ->
    stub = sinon.stub()
    @$el.wbpaginator(total: 100, page: 10, change: stub)

    @$el.find('.wbc-next-pager-link').click()

    expect(stub).to.has.not.been.called

  _.each [1, 5, 10], (page) ->
    it "should move to page #{page} when corresponding pager link is clicked", ->
      @$el.wbpaginator(total: 100, page: 3)

      @$el.find('.wbc-pager-link').eq(page - 1).click()

      expect(@$el.wbpaginator('option', 'page')).to.be.equal(page)
      expect(@$el.find('.wbc-pager-text')).to.has.$text("Página #{page} de 10")
  , @

  _.each [1, 5, 10], (page) ->
    it "should trigger change event when pager link #{page} is clicked", ->
      stub = sinon.stub()
      @$el.wbpaginator(total: 100, page: 3, change: stub)

      @$el.find('.wbc-pager-link').eq(page - 1).click()

      expect(stub).to.has.been.calledOnce
      expect(stub.firstCall.args[1]).to.be.eql(total: 100, max: 10, page: page, offset: 10 * (page - 1))
  , @

  it 'should render at most 10 pagers', ->
    @$el.wbpaginator(total: 100, max: 8)

    expect(@$el.find('.wbc-pager').length).to.be.equal(10)

  it 'should render ellipsis in the middle of the pagers when there are more than 10 pages', ->
    @$el.wbpaginator(total: 150, max: 10)

    expect(@$el.find('.wbc-pager-ellipsis')).to.existExact(1)
    $pagerEllipsis = @$el.find('.wbc-pagers').children().eq(5)
    expect($pagerEllipsis).to.has.$class('wbc-pager-ellipsis')
    expect($pagerEllipsis).to.has.$text('...')

  it 'should not change page if ellipsis pager is clicked', ->
    stub = sinon.stub()
    @$el.wbpaginator(total: 150, max: 10, page: 5, change: stub)

    @$el.find('.wbc-pager-ellipsis').click()

    expect(stub).to.not.has.been.called
    expect(@$el.wbpaginator('option', 'page')).to.be.equal(5)

  it 'should not render ellipsis if total pages are less than 10', ->
    @$el.wbpaginator(total: 90, max: 10)

    expect(@$el.find('.wbc-pager-ellipsis')).to.not.exist

  it 'should render first 5 pagers and last 5 pagers if total pagers are more than 10', ->
    stub = sinon.stub()
    @$el.wbpaginator(total: 140, max: 10, change: stub)

    $pagers = @$el.find('.wbc-pager')
    expectedPages = ['1', '2', '3', '4', '5', '10', '11', '12', '13', '14']
    for index in [0..9]
      $pager = $pagers.eq(index)
      expect($pager).to.has.$text(expectedPages[index])

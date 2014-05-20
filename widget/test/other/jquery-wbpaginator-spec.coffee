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

  it 'should render paginator hidden if total is not specified', ->
    @$el.wbpaginator()

    expect(@$el).to.not.be.displayed
    expectPaginatorIsRendered.call(@)

  it 'should render paginator hidden if there is just one page', ->
    @$el.wbpaginator(total: 10)

    expect(@$el).to.not.be.displayed
    expectPaginatorIsRendered.call(@)

  it 'should render paginator visible if there are several pages', ->
    @$el.wbpaginator(total: 100)

    expect(@$el).to.be.displayed
    expectPaginatorIsRendered.call(@)

  it 'should render page text', ->
    @$el.wbpaginator(total: 100)

    $pager = @$el.find('p.wbc-pager-text')
    expect($pager).to.existExact(1)
    expect($pager).to.has.$text('Página 1 de 10')

  it 'should render previous pager', ->
    @$el.wbpaginator(total: 100, page: 5)

    $previousPager = @$el.find('.wbc-previous-pager')
    expect($previousPager).to.has.$class('pager-prev')
    $pagerLink = $previousPager.children('a')
    expect($pagerLink).to.has.$text(' Ant')
    $spanArrow = $pagerLink.children('span')
    expect($spanArrow).to.existExact(1)
    expect($spanArrow).to.has.$class('iconFont-arrowLeft')

  it 'should render previous pager as the first pager', ->
    @$el.wbpaginator(total: 100)

    $firstPager = @$el.find('ul.wbc-pagers').children().first()
    expect($firstPager).to.has.$class('wbc-previous-pager')

  it 'should render previous pager invisible if current page is first page', ->
    @$el.wbpaginator(total: 100, page: 1)

    $previousPager = @$el.find('.wbc-previous-pager')
    expect($previousPager).to.be.invisible

  it 'should render next pager', ->
    @$el.wbpaginator(total: 100)

    $nextPager = @$el.find('.wbc-next-pager')
    expect($nextPager).to.has.$class('pager-next')
    $pagerLink = $nextPager.children('a')
    expect($pagerLink).to.has.$text('Sig ')
    $spanArrow = $pagerLink.children('span')
    expect($spanArrow).to.existExact(1)
    expect($spanArrow).to.has.$class('iconFont-arrowRight')

  it 'should render next pager as the last pager', ->
    @$el.wbpaginator(total: 100)

    $firstPager = @$el.find('ul.wbc-pagers').children().last()
    expect($firstPager).to.has.$class('wbc-next-pager')

  it 'should render next pager invisible if current page is the last page', ->
    @$el.wbpaginator(total: 100, page: 10)

    $nextPager = @$el.find('.wbc-next-pager')
    expect($nextPager).to.be.invisible

  it 'should render pagers', ->
    @$el.wbpaginator(total: 150)

    expectPagersFor.call(@, [1, 2, 3, 4, 5, 11, 12, 13, 14, 15])

  _.each [1, 3, 5, 7, 10], (totalPages) ->
    it "should render visible pagers if pages <= 10: #{totalPages}", ->
      max = 10
      @$el.wbpaginator(total: totalPages * max, max: max)

      expectPagersFor.call(@, [1..totalPages])

    it "should not display ellipsis pager if pages <= 10: #{totalPages}", ->
      max = 10
      @$el.wbpaginator(total: totalPages * max, max: max)

      $pagerEllipsis = @$el.find('.wbc-ellipsis-pager')
      expect($pagerEllipsis).to.not.be.displayed
  , @

  it 'should display ellipsis pager it there are more than 10 pages', ->
    @$el.wbpaginator(total: 150)

    $pagerEllipsis = @$el.find('.wbc-pagers').children().eq(6)
    expect($pagerEllipsis).to.has.$class('wbc-ellipsis-pager')
    expect($pagerEllipsis).to.be.displayed
    expect($pagerEllipsis.find('a')).to.has.$text('...')

  it 'should render current page option', ->
    @$el.wbpaginator(total: 100, page: 5)

    expectCurrentPage.call(@, 5)

  it 'should render correct total pages', ->
    @$el.wbpaginator(total: 53, max: 5)

    expect(@$el.find('.wbc-pager-text')).to.has.$text('Página 1 de 11')

  it 'should move to previous page if previous pager is clicked', ->
    @$el.wbpaginator(total: 100, page: 10)

    @$el.find('.wbc-previous-pager').click()
    expectCurrentPage.call(@, 9)

  it 'should trigger change event when previous pager is clicked', ->
    stub = sinon.stub()
    @$el.wbpaginator(total: 100, page: 10, change: stub)

    @$el.find('.wbc-previous-pager').click()

    expect(stub).to.has.been.calledOnce
    uiArg = stub.firstCall.args[1]
    expect(uiArg).to.be.eql(total: 100, max: 10, page: 9, offset: 80)

  it 'should not move to previous page when current page is first page', ->
    @$el.wbpaginator(total: 100, page: 1)

    @$el.find('.wbc-previous-pager').click()

    expectCurrentPage.call(@, 1)

  it 'should not trigger "change" event if trying to move below first page', ->
    stub = sinon.stub()
    @$el.wbpaginator(total: 100, page: 1, change: stub)

    @$el.find('.wbc-previous-pager').click()

    expect(stub).to.has.not.been.called

  it 'should move to next page when next pager is clicked', ->
    @$el.wbpaginator(total: 100, page: 1)

    @$el.find('.wbc-next-pager').click()

    expectCurrentPage.call(@, 2)

  it 'should trigger change event next page link is clicked', ->
    stub = sinon.stub()
    @$el.wbpaginator(total: 100, page: 1, change: stub)

    @$el.find('.wbc-next-pager').click()

    expect(stub).to.has.been.calledOnce
    uiArg = stub.firstCall.args[1]
    expect(uiArg).to.be.eql(total: 100, max: 10, page: 2, offset: 10)

  it 'should not move to next page if current page is last page', ->
    @$el.wbpaginator(total: 100, page: 10)

    @$el.find('.wbc-next-pager').click()

    expectCurrentPage.call(@, 10)

  it 'should not trigger "change" event if trying to move beyond last page', ->
    stub = sinon.stub()
    @$el.wbpaginator(total: 100, page: 10, change: stub)

    @$el.find('.wbc-next-pager').click()

    expect(stub).to.has.not.been.called

  _.each [1, 5, 10], (page) ->
    it "should move to page #{page} when corresponding pager is clicked", ->
      @$el.wbpaginator(total: 100, page: 3)

      @$el.find('.wbc-pager').eq(page - 1).click()

      expectCurrentPage.call(@, page)
  , @

  _.each [1, 5, 10], (page) ->
    it "should trigger change event when pager #{page} is clicked", ->
      stub = sinon.stub()
      @$el.wbpaginator(total: 100, page: 3, change: stub)

      @$el.find('.wbc-pager').eq(page - 1).click()

      expect(stub).to.has.been.calledOnce
      expectedUiArg = total: 100, max: 10, page: page, offset: 10 * (page - 1)
      expect(stub.firstCall.args[1]).to.be.eql(expectedUiArg)
  , @

  it 'should not trigger "change" event when current page pager is clicked', ->
    page = 3
    stub = sinon.stub()
    @$el.wbpaginator(total: 100, page: page, change: stub)

    @$el.find('.wbc-pager').eq(page - 1).click()

    expect(stub).to.not.has.been.called
    expectCurrentPage.call(@, page)

  it 'should not change page if ellipsis pager is clicked', ->
    stub = sinon.stub()
    @$el.wbpaginator(total: 150, page: 5, change: stub)

    @$el.find('.wbc-pager-ellipsis').click()

    expect(stub).to.not.has.been.called
    expectCurrentPage.call(@, 5, 15)

  it 'should not render ellipsis if total pages are less than 10', ->
    @$el.wbpaginator(total: 90, max: 10)

    expect(@$el.find('.wbc-pager-ellipsis')).to.not.exist

  it 'should render first and last 5 pagers if there are more than 10', ->
    stub = sinon.stub()
    @$el.wbpaginator(total: 140, max: 10, change: stub)

    expectPagersFor.call(@, [1, 2, 3, 4, 5, 10, 11, 12, 13, 14])

  it 'should show previous pager when moving to second page', ->
    @$el.wbpaginator(total: 100)

    @$el.find('.wbc-next-pager').click()
    expect(@$el.find('.wbc-previous-pager')).to.not.be.invisible

  it 'should hide previous pager when moving to first page', ->
    @$el.wbpaginator(total: 100, page: 2)

    @$el.find('.wbc-previous-pager').click()
    expect(@$el.find('.wbc-previous-pager')).to.be.invisible

  it 'should hide previous pager when clicking first page pager', ->
    @$el.wbpaginator(total: 100, page: 5)

    @$el.find('.wbc-pager').first().click()
    expect(@$el.find('.wbc-previous-pager')).to.be.invisible

  it 'should show next pager when moving to penultimate page', ->
    @$el.wbpaginator(total: 100, page: 10)

    @$el.find('.wbc-previous-pager').click()
    expect(@$el.find('.wbc-next-pager')).to.not.be.invisible

  it 'should hide next pager when moving to last page', ->
    @$el.wbpaginator(total: 100, page: 9)

    @$el.find('.wbc-next-pager').click()
    expect(@$el.find('.wbc-next-pager')).to.be.invisible

  it 'should hide next pager when clicking last page pager', ->
    @$el.wbpaginator(total: 100, page: 5)

    @$el.find('.wbc-pager').last().click()
    expect(@$el.find('.wbc-next-pager')).to.be.invisible

  expectPaginatorIsRendered = () ->
    expect(@$el.find('p.wbc-pager-text')).to.existExact(1)
    $pagersList = @$el.find('ul.wbc-pagers')
    expect($pagersList).to.existExact(1)
    $pagers = $pagersList.children('li')
    expect($pagers.length).to.be.equal(13)
    expect($pagers.filter('.wbc-previous-pager')).to.existExact(1)
    expect($pagers.filter('.wbc-pager')).to.existExact(10)
    expect($pagers.filter('.wbc-next-pager')).to.existExact(1)
    expect($pagers.filter('.wbc-ellipsis-pager')).to.existExact(1)
    for pager in $pagers
      $pager = $(pager)
      expect($pager.find('a')).to.existExact(1)

  expectPagersFor = (pages) ->
    $pagers = @$el.find('.wbc-pager')
    $pagers.slice(0, pages.length).each (index, pager) ->
      page = pages[index]
      $pager = $(pager)
      expect($pager).to.be.displayed
      expect($pager.data('_page')).to.be.equal(page)
      expect($pager.find('a')).to.has.$text(page.toString())

    $pagers.slice(pages.length).each (index, pager) ->
      $pager = $(pager)
      expect($pager).to.not.be.displayed
      expect($pager.data('_page')).to.not.be.ok
      expect($pager).to.has.$text('')

  expectCurrentPage = (page, totalPages = 10) ->
    expectedPagerText = "Página #{page} de #{totalPages}"
    expect(@$el.find('.wbc-pager-text')).to.has.$text(expectedPagerText)
    $currentPage = @$el.find('.wbc-current-page')
    expect($currentPage).to.existExact(1)
    expect($currentPage.data('_page')).to.be.equal(page)
    expect(@$el.wbpaginator('option', 'page')).to.be.equal(page)

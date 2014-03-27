chai.Assertion.addProperty('rendered', function () {
  var selector = this._obj.selector;
  this.assert(
      this._obj.length > 0
    , 'expected #{selector} is not rendered'
    , 'expected #{selector} is rendered'
  );
});

chai.Assertion.addChainableMethod('id', function (id) {
  this.assert(
      this._obj.attr('id') === id
    , 'element has not id #{id}'
    , 'element has id #{id}'
  );
});

chai.Assertion.addChainableMethod('class', function (clazz) {
  this.assert(
      this._obj.hasClass(clazz)
    , 'the element has not class #{clazz}'
    , 'the element has class #{clazz}'
  );
});

// Create `window.describe` etc. for our BDD-like tests.
mocha.setup({ui: 'bdd'});

// Create another global variable for simpler syntax.
window.expect = chai.expect;

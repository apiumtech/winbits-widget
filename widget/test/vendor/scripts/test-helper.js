chai.Assertion.addProperty('rendered', function () {
  this.assert(
      this._obj.length > 0
    , 'expected #{this._obj.selector} is rendered'
    , 'expected #{this._obj.selector} is not rendered'
  );
});

// Create `window.describe` etc. for our BDD-like tests.
mocha.setup({ui: 'bdd'});

// Create another global variable for simpler syntax.
window.expect = chai.expect;

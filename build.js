({
//  appDir: './',
  baseUrl: '.',
//  dir: './dist',
  modules: [
    {
      name: 'main'
    }
  ],
  fileExclusionRegExp: /^(r|build)\.js$/,
//  optimizeCss: 'standard',
  removeCombined: true,
  paths: {
    porthole: 'js/porthole',
    modernizr: 'include/js/libs/modernizr-2.6.2',
    jquery: 'include/js/libs/jquery-1.8.3.min',
    jqueryBrowser: 'include/js/libs/jquery.browser.min',
    jqueryUI: 'include/js/libs/',
    highslide: 'include/js/libs',
    jqueryValidate: 'include/js/libs',
    script: 'include/js/script'
  },
  shim: {
    underscore: {
      exports: '_'
    },
    backbone: {
      deps: [
        'underscore',
        'jquery'
      ],
      exports: 'Backbone'
    },
    backboneLocalstorage: {
      deps: ['backbone'],
      exports: 'Store'
    }
  }
})
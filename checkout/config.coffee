exports.config =
  # See http://brunch.io/#documentation for docs.
  files:
    javascripts:
      joinTo:
        'javascripts/app.js': /^app/
        'javascripts/vendor.js': /^vendor/
        'test/javascripts/test.js': /^test[\\/](?!vendor)/
        'test/javascripts/test-vendor.js': /^test[\\/](?=vendor)/
      order:
        # Files in `vendor` directories are compiled before other files
        # even if they aren't specified in order.before.
        before: [
          'vendor/scripts/xtra/easyXDM-2.4.18.25.js',
          'vendor/scripts/json2.js',
          'vendor/scripts/console-polyfill.js',
          'vendor/scripts/jquery-ui-1.10.3.custom.js',
          'vendor/scripts/lodash-1.2.0.js',
          'vendor/scripts/backbone-1.0.0.js',
          'vendor/scripts/jquery.browser.min.js'
        ]
        after: [
          'test/vendor/scripts/test-helper.js',
          'vendor/scripts/script.js', # Script de Yadira
          'vendor/scripts/winbits/jquery-location-select.coffee'
        ]

    stylesheets:
      joinTo:
        'stylesheets/app.css': /^(app\/styles\/app|vendor)/
        'test/stylesheets/test.css': /^test/
      order:
        after: ['vendor/styles/helpers.css',
                'vendor/styles/winbitsMain.css'
        ]
    templates:
      joinTo: 'javascripts/app.js'

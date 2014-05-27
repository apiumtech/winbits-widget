exports.config =
# See http://brunch.io/#documentation for docs.
  files:
    javascripts:
      joinTo:
        'javascripts/app.js': /^app/
        'javascripts/vendor.js': /^(bower_components|vendor)/
        'test/javascripts/test.js': /^test[\\/](?!vendor)/
        'test/javascripts/test-vendor.js': /^test[\\/]vendor/
      order:
      # Files in `vendor` directories are compiled before other files
      # even if they aren't specified in order.before.
        before: [
          'bower_components/console-polyfill/index.js'
          'bower_components/jquery/dist/jquery.js'
          'bower_components/jquery.browser/dist/jquery.browser.js'
          'vendor/scripts/winbits/init-env.coffee'
          'bower_components/json2/json2.js'
          'vendor/scripts/xtra/easyXDM-2.4.19.3.js'
          'bower_components/yepnope/yepnope.js'
          'vendor/scripts/winbits/init-rpc.coffee'
          'vendor/scripts/jquery-ui-1.10.3.custom.js'
        ],
        after: [
          'bower_components/moment-timezone/moment-timezone.js'
          'vendor/scripts/messages_es.js'
          'vendor/scripts/script.js', # Script de Yadira
          'vendor/scripts/winbits/jquery-location-select.coffee'
          'vendor/scripts/winbits/post-load-vendor.coffee'
          'test/vendor/scripts/test-helper.js'
        ]

    stylesheets:
      joinTo:
        'stylesheets/winbits/app.css': /^(app|vendor|bower_components)/
        'test/stylesheets/test.css': /^test/
      order:
        after: [
          'app/styles/winbits.css',
          'vendor/styles/helpers.css'
        ]

    templates:
      joinTo: 'javascripts/app.js'

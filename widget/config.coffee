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
          'bower_components/jquery/dist/jquery.js',
          'vendor/scripts/winbits/init-config.coffee', # TODO: Tratar de pasarlo al winbits.js
          'bower_components/json2/json2.js',
          'vendor/scripts/xtra/easyXDM-2.4.19.3.js',
          'vendor/scripts/winbits/init-rpc.coffee'
        ],
        after: [
          'vendor/scripts/messages_es.js',
          'vendor/scripts/winbits/post-load-vendor.coffee',
          'app/initialize.coffee',
          'test/vendor/scripts/test-helper.js'
        ]

    stylesheets:
      joinTo:
        'stylesheets/app.css': /^(app\/styles\/app|vendor)/
        'stylesheets/checkout.css': /^(app\/styles\/checkout|vendor)/
        'test/stylesheets/test.css': /^test/
      order:
        after: ['vendor/styles/helpers.css']

    templates:
      joinTo: 'javascripts/app.js'
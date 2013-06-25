exports.config =
  # See http://brunch.io/#documentation for docs.
  files:
    javascripts:
      joinTo:
        'scripts/app.js': /^app/
        'scripts/vendor.js': /^vendor/
        'test/scripts/test.js': /^test[\\/](?!vendor)/
        'test/scripts/test-vendor.js': /^test[\\/](?=vendor)/
      order:
        # Files in `vendor` directories are compiled before other files
        # even if they aren't specified in order.before.
        before: [
          'vendor/scripts/modernizr-2.6.2.js',
          'vendor/scripts/jquery-1.8.3.min.js'
        ]
        after: [
          'vendor/highslide/highslide.config.js',
          'vendor/scripts/script.js'
        ]

    stylesheets:
      defaultExtension: 'less'
      joinTo:
        'stylesheets/app.css': /^(app|vendor)/
        'test/stylesheets/test.css': /^test/
      order:
        #after: ['vendor/styles/helpers.css']
        before: ['app/styles/style.less']

    templates:
      joinTo: 'scripts/app.js'
  plugins:
    less:
      dumpLineNumbers: 'comments'

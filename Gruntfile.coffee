path = require('path')
escapeChar = process.platform.match(/^win/) ? '^' : '\\'
cwd = process.cwd().replace(/( |\(|\))/g, escapeChar + '$1')

# css files to concat/minify
cssToConcat = [
  'bower_components/foundation/css/foundation.css'
  '.tmp/css/*.css'
]

# js files to concat/minify
jsToConcat = [
  '.tmp/js/dexie-patch.js',
  'bower_components/jquery/dist/jquery.js'
  'bower_components/jquery.maskedInput/dist/jquery.maskedInput.js'
  'bower_components/jqueryui/jquery-ui.js'
  'bower_components/dexie/dist/latest/Dexie.js'
  '.tmp/js/secret.js'
  '.tmp/js/app.js'
]

module.exports = (grunt) ->

  grunt.initConfig

    pkg:
      grunt.file.readJSON 'package.json'

    # grunt shell
    shell:
      bower:
        command: path.resolve(cwd + '/node_modules/.bin/bower --allow-root install')
        options:
          stdout: true,
          stdin: false

    # grunt clean
    clean: [
      '.tmp/public/**'
      'dist'
    ]
 
    # grunt sass
    sass:
      compile:
        options:
          style: 'expanded'
        files: [
          expand: true
          cwd: 'scss'
          src: ['**/*.scss']
          dest: '.tmp/css'
          ext: '.css'
        ]
 
    # grunt coffee
    coffee:
      compile:
        expand: true
        cwd: 'coffee'
        src: ['**/*.coffee']
        dest: '.tmp/js'
        ext: '.js'

    # grunt concat
    concat:
      js:
        src: jsToConcat
        dest: '.tmp/concat/production.js'
      css:
        src: cssToConcat
        dest: '.tmp/concat/production.css'

    # grunt uglify
    uglify:
      dist:
        src: ['.tmp/concat/production.js']
        dest: 'dist/production.min.js'

    # grunt cssmin
    cssmin:
      dist:
        src: ['.tmp/concat/production.css']
        dest: 'dist/production.min.css'

    # grunt watch
    watch:
      scripts:
        files: [
          '**/*.html'
          '**/*.coffee'
          '**/*.scss'
        ]
        tasks: ['default']

    # grunt zip
    zip:
      'pkg/SignupApp.zip': [
        'dist/**/*'
        'fonts/**/*'
        'img/**/*'
        'background.js'
        'manifest.json'
        'window.html'
      ]
 
  # load plugins
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-shell'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-zip'

  # tasks
  grunt.registerTask 'default', [
    'clean'
    'shell'
    'sass'
    'coffee'
    'concat'
    'uglify'
    'cssmin'
  ]
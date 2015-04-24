path = require 'path'

module.exports = (grunt) ->

  grunt.initConfig
  	pkg: grunt.file.readJSON 'package.json'

  	coffee:
  		avocado:
  			files: [
  				cwd: 'src/'
  				src: [
  					'**/*.coffee'
  					'!**/*.spec.coffee'
  				]
  				dest: 'build/raw/dev'
  				expand: true
  				ext: '.js'
  			]

  	copy:
  		avocado:
  			files: [
  				cwd: 'src/'
  				src: [
  					'**/*.js'
  					'!**/*.spec.js'
  				]
  				dest: 'build/raw/dev'
  				expand: true
  			]

  	uglify:
  		avocado:

  			files: [
  				expand: true
  				cwd: 'build/raw/dev'
  				src: '**/*.js'
  				dest: 'build/raw/production'
  			]

  	wrap:
  		avocado:

  			files: [
  				cwd: 'build/raw/dev/'
  				expand: true
  				src: ['**/*.js']
  				dest: 'build/wrapped/dev/'
  			]

  			options:
  				wrapper: (filepath) ->

  					moduleName = filepath.substr 'build/raw/dev/'.length
  					dirname = path.dirname moduleName
  					extname = path.extname moduleName

  					moduleName = "#{dirname}/#{path.basename moduleName, extname}"

  					if moduleName?
  						["__avocadoModules['#{moduleName}'] = function(module, exports, require, __dirname, __filename) {\n", '};\n']
  					else
  						['', '']

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-wrap'

  grunt.registerTask 'default', ['coffee', 'copy', 'wrap']
  grunt.registerTask 'production', ['default', 'uglify']

fs = require 'fs'
path = require 'path'

module.exports = (grunt) ->

	sourceDirectories = [
		'scripts/**/*.coffee'
	]
	
	sourceMapping = grunt.file.expandMapping sourceDirectories, 'js/',
		rename: (destBase, destPath) ->
			destBase + destPath.replace /\.coffee$/, ".js"
	
	grunt.initConfig
		pkg: grunt.file.readJSON 'package.json'
		
		coffee:
			compile:
				files: sourceMapping
			
		copy:
			main:
				files: [
					src: [
						'scripts/**/*.js'
					]
					dest: 'js/'
					expand: true
				]
				
		wrap:
			modules:
				src: ['js/**/*.js']
				dest: 'js/wrapped/'
				wrapper: (filepath) ->
					
					moduleName = filepath.substr 11
					dirname = path.dirname moduleName
					extname = path.extname moduleName
					moduleName = path.join dirname, path.basename moduleName, extname 
					
					if moduleName?
						["requires_['#{moduleName}'] = function(module, exports) {\n\n", '\n}\n']
					else
						['', '']
		
		uglify:
			options:
				banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
			build:
				src: [
					'js/wrapped/**/*.js'
				]
				dest: 'build/<%= pkg.name %>.min.js'
				
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-wrap'
	
	grunt.registerTask 'default', ['coffee', 'copy', 'wrap']

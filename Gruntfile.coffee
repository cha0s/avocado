path = require 'path'

module.exports = (grunt) ->

	sourceMapping = grunt.file.expandMapping ['src/**/*.coffee'], 'build/',
		rename: (destBase, destPath) ->
			
			destPath = destPath.replace 'src/', 'raw/dev/'
			destBase + destPath.replace /\.coffee$/, ".js"
			
	# Don't include test suites
	sourceMapping = sourceMapping.filter (file) ->
		not file.src[0].match '\.spec\.coffee'
	
	sourceMappingObject = {}
	for file in sourceMapping
		continue unless file?
		{src, dest} = file
		
		sourceMappingObject[dest] = src[0]
		
	grunt.initConfig
		pkg: grunt.file.readJSON 'package.json'
		
		coffee:
			avocado:
				files: sourceMappingObject
		
		copy:
			avocado:
				files: [
					cwd: 'src/'
					src: [
						'**/*.js'
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
						
						moduleName = path.join dirname, path.basename moduleName, extname 
						
						if moduleName?
							["requires_['#{moduleName}'] = function(module, exports, require, __dirname, __filename) {\n\n", '\n};\n']
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

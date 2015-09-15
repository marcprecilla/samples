module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json'),
    sass:
      dist: {
        options: {
          loadPath: 'src/stylesheets/'
        },
        files: {
          '../htdocs/css/application.css' : 'src/stylesheets/application.scss',
        }
      },
      dist_admin: {
        options: {
          loadPath: 'src/stylesheets/'
        },
        files: {
          '../htdocs/css/application.admin.css' : 'src/stylesheets/application_admin.scss',
        }
      }
    ,
    copy:
      main: {
        files: [
              #includes files within path
              {expand: true, flatten: true, src: ['src/javascripts/common/*.js'], dest: 'build/js', filter: 'isFile'},
            ],
      }
    ,
    coffee:
      compileJoined:
        options: {},
        files:
          'build/js/common.js': 'src/javascripts/common/*.coffee',
          'build/js/pages.js': 'src/javascripts/pages/*.coffee',
          'build/js/final.js':'src/javascripts/final.coffee'
      ,
      compileAdmin:
        options: {
          sourceMap:true,
          join: true
        },
        files:
          'build/js/common.js': 'src/javascripts/common/*.coffee',
          'build/js/admin.js': 'src/javascripts/admin/*.coffee'

    ,
    concat:
      options: {
        separator: ';\r/*new file*/\r'
      },
      dist: {
        src: [
          'build/js/namespaces.js',
          'build/js/common.js',
          'build/js/pages.js',
          'build/js/final.js'
        ],
        dest: 'build/<%= pkg.name %>.js'
      },
      dist_admin: {
        src: [
          'build/js/namespaces.js',
          'build/js/common.js',
          'build/js/admin.js'
        ],
        dest: 'build/<%= pkg.name %>.admin.js'
      }

    ,
    concat_sourcemap:
      options: {},
      target: {
        files: {
          '../htdocs/css/<%= pkg.name %>.lib.css': ['src/stylesheets/lib/*.css'],
          '../htdocs/js/<%= pkg.name %>.lib.js': ['src/javascripts/lib/*.js']
        }
      }
    ,
    uglify:
      site_target: {
        files: {
          '../htdocs/js/<%= pkg.name %>.min.js': ['build/<%= pkg.name %>.js']
        }
      },
      site_admin: {
        files: {
          '../htdocs/js/<%= pkg.name %>.admin.min.js': ['build/<%= pkg.name %>.admin.js']
        }
      },
    ,
    clean: [
      "build/*"
    ],
    watch:
      sass: {
        files: [
          'src/stylesheets/*.scss',
          'src/stylesheets/common/*.scss',
          'src/stylesheets/pages/*.scss',
        ]
        tasks:
          [
            'sass:dist'
          ]
      },
      sass_admin: {
        files: [
          'src/stylesheets/admin/*.scss'
        ]
        tasks:
          [
            'sass:dist_admin'
          ]
      }
      css: {
        files: [
          'src/stylesheets/lib/*.css',
          'src/javascripts/lib/*.js',
        ]
        tasks:
          [
            'concat_sourcemap'
          ]
      },
      coffee: {
        files: [
          'src/javascripts/final.coffee',
          'src/javascripts/common/*.js',
          'src/javascripts/common/*.coffee',
          'src/javascripts/pages/*.coffee',
          'src/javascripts/pages/*.js',
        ]
        tasks:
          [
            'copy',
            'coffee:compileJoined',
            'concat:dist',
            'uglify:site_target',
            'clean'
          ]
      },
      coffee_admin: {
        files: [
          'src/javascripts/common/*.js',
          'src/javascripts/common/*.coffee',
          'src/javascripts/admin/*.coffee'
        ]
        tasks:
          [
            'copy',
            'coffee:compileAdmin'
            'concat:dist_admin',
            'uglify:site_admin',
            'clean'
          ]
      }
    ,

  grunt.loadNpmTasks 'grunt-contrib-sass';
  grunt.loadNpmTasks 'grunt-contrib-concat';
  grunt.loadNpmTasks 'grunt-concat-sourcemap';
  grunt.loadNpmTasks 'grunt-contrib-coffee';
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch';
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-clean');

  grunt.registerTask 'default', ['copy','sass','concat_sourcemap','coffee','concat','uglify','clean','watch'];

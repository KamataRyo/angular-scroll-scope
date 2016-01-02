gulp    = require 'gulp'
plumber = require 'gulp-plumber'
rename  = require 'gulp-rename'
path    = require 'path'
# build
coffee  = require 'gulp-coffee'
uglify  = require 'gulp-uglify'
#test
connect = require 'gulp-connect'
KarmaServer  = require('karma').Server;


base = './'
srcs =
    html: base + '*.html'
    coffee: base + 'coffee/**/*.coffee'
    spec: base + 'spec/**/*.coffee'
watching = Object.values(srcs)

host = 'localhost'
port = 8001

gulp.task 'coffee', () ->
  gulp.src [srcs.coffee]
    .pipe plumber()
    .pipe coffee(bare: false)
    .on 'error', (err) ->
        console.log err.stack
    .pipe rename (file) ->
        file.basename = 'app'
    .pipe gulp.dest base + '/'
    .pipe uglify()
    .pipe rename (file) ->
        file.basename += '.min'
    .pipe gulp.dest base + '/'


gulp.task 'karma',['coffee'], (done) ->
    new KarmaServer {
        configFile: __dirname + '/bin/karma.conf.coffee'
        singleRun: true
    }, done
        .start()


# create server
gulp.task 'connect', () ->
  options =
    root: path.resolve base
    livereload: true
    port: port
    host: host
  connect.server options

gulp.task 'reload', ['coffee'] , () ->
  gulp.src watching
    .pipe connect.reload()

gulp.task 'watch', () ->
  gulp.watch watching, ['coffee','karma', 'reload']


gulp.task 'default', ['coffee']
gulp.task 'dev', ['coffee','karma','connect', 'watch' ]

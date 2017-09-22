# Utilities
gulp = require("gulp")
streamqueue = require("streamqueue")
gutil = require("gulp-util")
rimraf = require("gulp-rimraf")
concat = require("gulp-concat")
gulpif = require('gulp-if')
templateCache = require('gulp-angular-templatecache')
plumber = require('gulp-plumber');
gulp_run = require('gulp-run');

# Pre-Processors
coffee = require("gulp-coffee")
sass = require("gulp-ruby-sass")
jade = require('gulp-jade')
markdown = require('gulp-markdown')

# Minification
uglify = require("gulp-uglify")
minifyHTML = require("gulp-minify-html")
minifyCSS = require("gulp-minify-css")

# Angular Helpers
ngAnnotate = require("gulp-ng-annotate")
htmlify = require('gulp-angular-htmlify')

# Dev Server
connect = require('gulp-connect')

errorHandler = ->
  plumber (error) ->
    console.log error
    this.emit('end')

# PATH VARIABLES
# =================================================
config =
  devServerPort: 9000 # If you change this, you must also change it in protractor-conf.js

paths =
  app:
    scripts: ["app/javascripts/app.{coffee,js}", "app/javascripts/**/*.{coffee,js}"] # All .js and .coffee files, starting with app.coffee or app.js
    styles: "app/stylesheets/**/*.{scss,sass,css}" # css and scss files
    pages: "app/pages/*.{html,jade,md,markdown}" # All html, jade,and markdown files that can be reached directly
    templates: "app/templates/**/*.{html,jade,md,markdown}" # All html, jade, and markdown files used as templates within the app
    images: "app/images/*.{svg,png,jpg,jpeg,gif}" # All image files
    static: "app/static/*.*" # Any other static content such as the favicon

  vendor:
    scripts: [
      "vendor/bower/jquery/dist/jquery.js"
      "vendor/bower/jquery-ui/jquery-ui.min.js"
      "vendor/bower/angular/angular.js"
      "vendor/bower/angular-ui-router/release/angular-ui-router.js"
      "vendor/bower/angular-bootstrap/ui-bootstrap-tpls.js"
      "vendor/bower/angular-resource/angular-resource.js"
    ]
    styles: [
      "vendor/bower/jquery-ui/themes/base/jquery-ui.min.css"
    ] # Bootstrap and Font-Awesome are included using @import in main.scss
    fonts: "vendor/bower/font-awesome/fonts/*.*"

# SCRIPT-RELATED TASKS
# =================================================
# Compile, concatenate, and (optionally) minify scripts
# Also pulls in 3rd party libraries and convertes
# angular templates to javascript
# =================================================
# Gather 3rd party javascripts
compileVendorScripts = ->
  gulp.src(paths.vendor.scripts)
    .pipe(errorHandler())

# Gather and compile App Scripts from coffeescript to JS
isCoffeScript = (file) ->
   file_array = file.history[0].split('/')
   file_name = file_array[file_array.length-1]
   /\.(coffee)$/i.test file_name

compileAppScripts = ->
  coffeestream = coffee({bare:true})
  coffeestream.on('error', gutil.log)
  appscripts = gulp.src(paths.app.scripts)
    .pipe(errorHandler())
    .pipe(gulpif(isCoffeScript, coffeestream))
    .pipe(ngAnnotate())

# Templates are compiled into JS and placed into Angular's
# template caching system

isJade = (file) ->
   file_array = file.history[0].split('/')
   file_name = file_array[file_array.length-1]
   /\.(jade)$/i.test file_name

isMarkdown = (file) ->
   file_array = file.history[0].split('/')
   file_name = file_array[file_array.length-1]
   /\.(md|markdown)$/i.test file_name

compileTemplates = ->
  templates = gulp.src(paths.app.templates)
    .pipe(errorHandler())
    .pipe(gulpif(isJade, jade()))
    .pipe(gulpif(isMarkdown, markdown()))
    .pipe(htmlify())
    .pipe(templateCache({
        root: "/templates/"
        standalone: false
        module: "weknow-test"
      }))

# Concatenate all JS into a single file
# Streamqueue lets us merge these 3 JS sources while maintaining order
concatenateAllScripts = ->
  streamqueue({objectMode: true}, compileVendorScripts(), compileAppScripts(), compileTemplates())
    .pipe(errorHandler())
    .pipe(concat("app.js"))

# Compile and concatenate all scripts and write to disk
buildScripts = (buildPath="generated", minify=false) ->
  scripts = concatenateAllScripts()
    .pipe(errorHandler())

  if minify
    scripts = scripts
      .pipe(uglify())

  scripts
    .pipe(gulp.dest("#{buildPath}/"))
    .pipe(connect.reload()) # Reload via LiveReload on change

gulp.task "scripts", -> buildScripts()
gulp.task "deploy_scripts", -> buildScripts("../api/app/assets/javascripts", true)
# =================================================



# STYLSHEETS
# =================================================
# Compile, concatenate, and (optionally) minify stylesheets
# =================================================
# Gather CSS files and convert scss to css
concatenateAllStyles = ->
  streamqueue({objectMode: true}, compileVendorStyles(), compileAppStyles())
    .pipe(errorHandler())
    .pipe(concat("app.css"))

compileVendorStyles = ->
  gulp.src(paths.vendor.styles)

isSass = (file) ->
   file_array = file.history[0].split('/')
   file_name = file_array[file_array.length-1]
   /\.(scss|sass)$/i.test file_name


compileAppStyles = ->
  gulp.src(paths.app.styles)
    .pipe(errorHandler())
    .pipe(gulpif(isSass,
      sass({
        sourcemap: false,
        unixNewlines: true,
        style: 'nested',
        debugInfo: false,
        quiet: false,
        lineNumbers: true,
        bundleExec: true,
        loadPath: [
          "vendor/bower/bootstrap-sass/assets/stylesheets/"
          "vendor/bower/font-awesome/scss/"
        ]
      })
      .on('error', gutil.log)
    ))

# Compile and concatenate css and then write to disk
buildStyles = (buildPath="generated", minify=false) ->
  styles = concatenateAllStyles()
    .pipe(errorHandler())

  if minify
    styles = styles
      .pipe(minifyCSS())

  styles
    .pipe(gulp.dest("#{buildPath}/"))
    .pipe(connect.reload()) # Reload via LiveReload on change

gulp.task "styles", -> buildStyles()
gulp.task "deploy_styles", -> buildStyles("../api//app/assets/stylesheets", true)
# =================================================


# HTML PAGES
# =================================================
# Html pages are root level pages. They can be either
# html, jade, or markdown
# =================================================
# Gather jade, html, and markdown files
# and convert to html. Then make them html5 valid.
compilePages = ->
  gulp.src(paths.app.pages)
    .pipe(errorHandler())
    .pipe(gulpif(/[.]jade$/, jade()))
    .pipe(gulpif(/[.]md|markdown$/, markdown()))
    .pipe(htmlify())

# Moves html pages to generated folder
buildPages = (buildPath="generated", minify=false) ->
  pages = compilePages()
    .pipe(errorHandler())

  if minify
    pages = pages
      .pipe(minifyHTML())

  pages
    .pipe(gulp.dest(buildPath))
    .pipe(connect.reload()) # Reload via LiveReload on change

gulp.task "pages", -> buildPages()
gulp.task "deploy_pages", -> buildPages("../api/public/", true)
# =================================================



# IMAGES
# =================================================
gulp.task 'fix_image_paths', ['deploy_styles'], () ->
  gulp_run('bundle exec rake befective:fix_images_before_assets_precompile', {cwd: '../api'}).exec()
# =================================================

# FONTS
# =================================================
# Move 3rd party fonts into the build folder
# =================================================
buildFonts = (buildPath="generated") ->
  gulp.src(paths.vendor.fonts)
    .pipe(errorHandler())
    .pipe(gulp.dest("#{buildPath}/fonts/"))

gulp.task "fonts", -> buildFonts()
gulp.task "deploy_fonts", -> buildFonts("../api/public/")
# =================================================

# STATIC CONTENT TASKS
# =================================================
# Move content in the static folder
buildStatic = (buildPath="generated") ->
  gulp.src(paths.app.static)
    .pipe(errorHandler())
    .pipe(gulp.dest("#{buildPath}/static/"))
    .pipe(connect.reload()) # Reload via LiveReload on change

gulp.task "static", -> buildStatic()
gulp.task "deploy_static", -> buildStatic("../api/public/")
# =================================================

# CLEAN
# =================================================
# Delete contents of the build folder
# =================================================
gulp.task "clean_deploy", ->
  return gulp.src(["deploy"], {read: false})
    .pipe(errorHandler())
    .pipe(rimraf({force: true}))
gulp.task "clean", ->
  return gulp.src(["generated"], {read: false})
    .pipe(errorHandler())
    .pipe(rimraf({force: true}))
# =================================================


# CLEAN
# =================================================
# Watch for file changes and recompile as needed
# =================================================
gulp.task 'watch', ->
  gulp.watch [paths.app.scripts, paths.app.templates, paths.vendor.scripts], ['scripts']
  gulp.watch [paths.app.styles, paths.vendor.styles], ['styles']
  gulp.watch [paths.app.pages], ['pages']
  gulp.watch [paths.vendor.fonts], ['fonts']
  gulp.watch [paths.app.static], ['static']

# LOCAL SERVER
# =================================================
# Run a local server, including LiveReload and
# API proxying
# =================================================
gulp.task 'server', ->
  connect.server({
    root: ['generated'],
    host: '0.0.0.0',
    port: config.devServerPort,
    livereload: true
    middleware: (connect, o) ->
      [
        (->
          url = require('url')
          proxy = require('proxy-middleware')
          options = url.parse('http://169.57.156.62:3003/api/')
          options.route = '/api' # requests to /api/* will be sent to the proxy
          proxy(options)
        )()
      ]
  })

gulp.task "compile", ["clean"], ->
  gulp.start("scripts", "styles", "pages", "fonts", "static")

gulp.task 'deploy', ['clean_deploy'], ->
  gulp.start("deploy_scripts", "deploy_styles", "deploy_fonts", "deploy_static", "fix_image_paths")

gulp.task "default", ["clean"], ->
  gulp.start("scripts", "styles", "pages", "fonts", "static", "server", "watch")

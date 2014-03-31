var config = require('./config.json'),
  templates = require('./template.json'),
  gulp = require('gulp'),
  gutil = require('gulp-util'),
  gulpif = require('gulp-if'),
  bytediff = require('gulp-bytediff'),
  rev = require('gulp-rev'),
  gzip = require('gulp-gzip'),
  clean = require('gulp-clean'),
  minify_html = require('gulp-minify-html'),
  myth = require('gulp-myth'),
  minify_css = require('gulp-csso'),
  include = require('gulp-include'),
  template = require('gulp-template'),
  jshint = require('gulp-jshint'),
  minify_js = require('gulp-uglify'),
  refresh = require('gulp-livereload'),
  open_browser = require('gulp-open'),
  vinyl_map = require('vinyl-map'),
  compass = require('gulp-compass'),
  sass = require('gulp-sass'),
  coffee = require('gulp-coffee');

var rework = require('rework');

/* Env */

var production = (gulp.env.production === true);

/* Server */

var connect = require('connect'),
  connect_livereload = require('connect-livereload'),
  lr_port = config.options.livereload.port,
  lr_server = require('tiny-lr')(),
  lh_vars = config.env.localhost,
  lh_port = lh_vars.url.port,
  lh_url = lh_vars.url.protocol + '://' + lh_vars.url.domain + ':' + lh_port + '/';

/* Path */

var build = './build/',
  source = './source/',
  htmlDir = source + '*.html',
  assetsDir = source + 'assets/**',
  cssDir = source + 'css/',
  scssDir = source + 'scss/',
  scssPath = scssDir + '*.scss',
  scssAllPath = [scssDir + '*/*.scss', scssDir + '*.scss'],
  jsDir = source + 'js/',
  jsPath = [jsDir + '*.js', jsDir + '*/*.js'],
  coffeeDir = source + 'coffee/',
  coffeePath = [coffeeDir + '*.coffee', coffeeDir + '*/*.coffee'];

/* Task */

var production_stream = function(stream, minify, rev_file) {

  return stream.pipe(bytediff.start())
    .pipe(gulpif(production, minify))
    .pipe(gulpif(production, bytediff.stop()))
    .pipe(gulpif((production && rev_file), rev()))
    .pipe(gulpif(production, gzip()));
};

gulp.task('html', function() {

  var stream = gulp.src(htmlDir);

  stream
    .pipe(template(templates));
  
  return stream
    .pipe(production_stream(stream, minify_html()))
    .pipe(gulp.dest(build));
    // .pipe(refresh(lr_server));
});



gulp.task('lr_server', function() {
  lr_server.listen(lr_port, function(err) {
    if (err) return gutil.log(err);
  });
});

gulp.task('server', function() {
  connect()
    .use(connect_livereload({
      port: lr_port
    }))
    .use(connect.static(build))
    .listen(lh_port);
});

gulp.task('compass', function() {
  gulp.src(scssPath)
    .pipe(compass({
      project: '.',
      css: build,
      sass: scssDir
    }))
    .pipe(gulp.dest(build))
    .pipe(refresh(lr_server));
});

gulp.task('coffee', function() {
  var stream = gulp.src(coffeeDir + '*.coffee')
    .pipe(include())
    .pipe(coffee())
    .pipe(gulp.dest(build))
    .pipe(refresh(lr_server));
    // .pipe(gulp.dest(jsDir));
});

gulp.task('compile', function() {
  gulp.src(jsDir + '*.js')
    .pipe(include())
    .pipe(gulp.dest(build))
    .pipe(refresh(lr_server));
});

// Copy all static assets
gulp.task('copy', function() {
  return gulp.src(assetsDir)
    .pipe(gulp.dest(build));
});

// gulp.task('clean', function() {
//   return gulp.src('build')
//     .pipe(clean({force: true}));
// });

gulp.task('default', function() {
  gulp.run('lr_server', 'server', 'html', 'compass', 'coffee', 'copy');
  setTimeout(function(){gulp.run('compile');}, 100);

  gulp.watch(htmlDir, function() {
    gulp.run('html');
  });
  gulp.watch(scssAllPath, function() {
    gulp.run('compass');
  });
  gulp.watch(coffeePath, function() {
    gulp.run('coffee');
    setTimeout(function(){gulp.run('compile');}, 100);
  });

  gulp.watch(assetsDir, function() {
    gulp.run('copy');
  });
});
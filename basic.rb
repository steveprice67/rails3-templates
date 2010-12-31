# Basic rails 3 app template with:
#
# - git repository
# - password_confirmation filtered
# - numbered (not timestamped) migrations
# - active record session store
# - jQuery instead of prototype
# - rspec instead of Test:Unit

template = File.basename(__FILE__)

run 'rm -f .gitignore'
file '.gitignore', <<-EOF
*.swp
**/*.swp
.bundle
Gemfile.lock
EOF
file 'db/.gitignore', "*.sqlite3\n"
file 'log/.gitignore', "*\n"
file 'tmp/.gitignore', "*\n"
file 'vendor/.gitignore', "*\n"

run 'cp config/database.yml config/database.yml.sample'
run 'echo database.yml > config/.gitignore'

run 'rm -f README'
run 'rm -r doc'
run 'rm -f public/images/rails.png'
run 'rm -f public/index.html'
run 'rm -f public/robots.txt'

['Gemfile', 'config/routes.rb', 'config/application.rb'].each do |f|
  gsub_file f, /^\s*(#.*)?$/, ''
  run "sed -i .orig -e '/^$/d' #{f}"
end
run "find . -name '*.orig' -print -delete"

inject_into_class 'config/application.rb', 'Application', <<-EOF
    config.active_record.timestamped_migrations = false
    config.filter_parameters += [:password_confirmation]
EOF

rake 'db:sessions:create'
run 'rm -f config/initializers/session_store.rb'
initializer 'session_store.rb', "#{app_const}.config.session_store :active_record_store, :key => '_#{app_name}_#{ActiveSupport::SecureRandom.hex(4)}_session'\n"
rake 'db:migrate'

append_file 'Gemfile', <<-EOF
group :test, :development do
  gem 'jquery-rails'
  gem 'rspec-rails'
end
EOF
run 'bundle install'

inside 'public/javascripts' do
  run 'rm -f controls.js dragdrop.js effects.js prototype.js rails.js'
end
initializer 'jquery-hack.rb', "OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE\n"
generate 'jquery:install'
run 'rm -f config/initializers/jquery-hack.rb'
run 'rm -f public/javascripts/jquery.js'
initializer 'jquery-rails.rb', "#{app_const}.config.action_view.javascript_expansions[:defaults] = %w(jquery.min rails)\n"

run 'rm -rf test'
generate 'rspec:install'

run "find . -type d -empty | egrep -v '(.git|tmp)' | xargs -I xxx touch 'xxx/.gitkeep'"

git :init
git :add => '.'
git :commit => "-m '#{template} template applied'"

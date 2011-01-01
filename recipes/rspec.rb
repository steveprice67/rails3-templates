append_file 'Gemfile', "group :test, :development do\n  gem 'rspec-rails'\nend"
run 'rm -rf test'
run 'bundle install'
generate 'rspec:install'

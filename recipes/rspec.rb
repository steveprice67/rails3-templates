append_file 'Gemfile', "group :test, :development do\n  gem 'rspec-rails'\nend"
remove_dir 'test'
run 'bundle install'
generate 'rspec:install'

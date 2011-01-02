append_file 'Gemfile', <<-EOF
group :test, :development do
  gem 'rspec-rails'
end
EOF
remove_dir 'test'
run 'bundle install'
generate 'rspec:install'

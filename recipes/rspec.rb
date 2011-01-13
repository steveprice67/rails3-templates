append_file 'Gemfile', <<-EOF
group :development, :test do
  gem 'rspec-rails'
  gem 'shoulda'
end
EOF
file '.rspec', "--colour\n"
remove_dir 'test'
run 'bundle install'
generate 'rspec:install'

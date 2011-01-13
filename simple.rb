# Rails 3 application template with simple authentication and cancan
# authorization.

apply File.expand_path('../_init.rb', __FILE__)

apply_recipes [
  :numbered_migrations,
  :database_yml,
  :jquery,
  :layout,
  :lorem,
  :rm,
  :rspec,
  :rails_info,
  :session_store,
  :simple_auth,
  :git,
]

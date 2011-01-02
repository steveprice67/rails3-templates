# Rails 3 application template with simple authentication and cancan
# authorization.

apply File.expand_path('../_init.rb', __FILE__)

apply_recipe :numbered_migrations
apply_recipe :database_yml
apply_recipe :jquery
apply_recipe :layout
apply_recipe :lorem
apply_recipe :rm
apply_recipe :rspec
apply_recipe :rails_info
apply_recipe :session_store
apply_recipe :simple_auth
apply_recipe :git

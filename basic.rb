# Basic rails 3 application template

apply File.expand_path('../_init.rb', __FILE__)

apply_recipes [
  :numbered_migrations,
  :database_yml,
  :jquery,
  :lorem,
  :rm,
  :rspec,
  :session_store,
  :git,
]

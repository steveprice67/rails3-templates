# Basic rails 3 application template

@recipe_dir = File.join(File.expand_path('..', __FILE__), 'recipes')
def apply_recipe(name)
  apply File.join(@recipe_dir, name)
end

apply_recipe 'database_yml.rb'
apply_recipe 'jquery.rb'
apply_recipe 'numbered_migrations.rb'
apply_recipe 'password_confirmation.rb'
apply_recipe 'rm.rb'
apply_recipe 'rspec.rb'
apply_recipe 'session_store.rb'

# best to perform this action last
apply_recipe 'git.rb'

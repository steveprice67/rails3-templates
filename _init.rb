#source_paths << File.expand_path('../templates', __FILE__)

@recipe_dir = File.expand_path('../recipes', __FILE__)

def apply_recipe(name)
  apply File.join(@recipe_dir, "#{name.to_s}.rb")
end

def apply_recipes(names)
  names.each { |name| apply_recipe name }
end

def next_migration_number
  num = Dir.glob('db/migrate/[0-9]*_*.rb').collect do |file|
    File.basename(file).split("_").first.to_i
  end.max.to_i + 1
  "%.3d" % num
end

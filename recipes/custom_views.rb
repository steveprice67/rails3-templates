initializer 'custom_views.rb', <<-EOF
ActionController::Base.prepend_view_path(File.join(Rails.root, 'app', 'custom',
  'views'))
EOF
file 'app/custom/views/.gitkeep', ''

rake 'db:sessions:create'
rake 'db:migrate'

run 'rm -f config/initializers/session_store.rb'
initializer 'session_store.rb', <<-EOF
#{app_const}.config.session_store :active_record_store,
  :key => '_#{app_name}_#{ActiveSupport::SecureRandom.hex(4)}_session'
EOF

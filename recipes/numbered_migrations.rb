inject_into_class 'config/application.rb', 'Application', <<-EOF
    config.active_record.timestamped_migrations = false
EOF

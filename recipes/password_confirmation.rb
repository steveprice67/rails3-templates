inject_into_class 'config/application.rb', 'Application', <<-EOF
    config.filter_parameters += [:password_confirmation]
EOF

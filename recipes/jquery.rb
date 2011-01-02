inside 'public/javascripts' do
  remove_file 'controls.js'
  remove_file 'dragdrop.js'
  remove_file 'effects.js'
  remove_file 'prototype.js'
  remove_file 'rails.js'
  get 'http://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js'
  peer = OpenSSL::SSL::VERIFY_PEER
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
  get 'https://github.com/rails/jquery-ujs/raw/master/src/rails.js'
  OpenSSL::SSL::VERIFY_PEER = peer
end

application "  config.action_view.javascript_expansions[:defaults] = %w(jquery.min rails)"

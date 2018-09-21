# frozen_string_literal: true

tcb = 'secure_apache'

# Remove Apache default file
file '/var/www/html/index.html' do
  action :delete
  only_if { node[tcb]['www']['remove_default_index'] }
end

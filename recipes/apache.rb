# frozen_string_literal: true

tcb = 'secure_apache'

# We always include the basics
include_recipe 'apache2::default'
include_recipe 'apache2::mod_headers'
include_recipe 'apache2::mod_rewrite'
include_recipe 'apache2::mod_ssl'

# Now include any extras
node[tcb]['apache']['extra_mods_to_install'].each do |name, _|
  include_recipe "apache2::mod_#{name}"
end

# Remove Apache default file
file '/var/www/html/index.html' do
  action :delete
  only_if { node[tcb]['www']['remove_default_index'] }
end

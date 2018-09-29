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

file '/var/www/html/index.html' do
  content '<h1>Welcome to Apache!</h1><p>Now make yourself a website:)</p>'
  only_if { node[tcb]['www']['create_default_index'] }
end

# Enable and harden TLS
apache_conf 'ssl_params' do
  source 'ssl_params.conf.erb'
  enable true
end

# HTTP host, permanent redirect
web_app '000-default' do
  template 'site-000.conf.erb'
  enable true
end

# Apache conf check ca_signed_cert? to switch cert path
cert_path = path_to_ssl_cert
key_path = path_to_ssl_key

# HTTPS host
web_app 'default-ssl' do
  template 'site-ssl.conf.erb'
  path_to_cert cert_path
  path_to_key key_path
  enable true
end

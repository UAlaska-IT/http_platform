# frozen_string_literal: true

tcb = 'http_platform'

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

# Common config for all HTTPS hosts
apache_conf 'ssl-host' do
  source 'ssl-host.conf.erb'
  enable false
end

# Default on Ubuntu
file '/etc/apache2/sites-available/default-ssl.conf' do
  action :delete
end

# Apache conf check ca_signed_cert? to switch cert path
www_server = www_server_name
plain_server = plain_server_name
aliases = generate_alias_pairs
cert_path = path_to_ssl_cert
key_path = path_to_ssl_key

# HTTP host, permanent redirect
web_app '000-site' do
  template 'site-000.conf.erb'
  www_server_name www_server
  plain_server_name plain_server
  additional_aliases aliases
  enable true
end

# HTTPS host
web_app 'ssl-site' do
  template 'site-ssl.conf.erb'
  www_server_name www_server
  plain_server_name plain_server
  additional_aliases aliases
  path_to_cert cert_path
  path_to_key key_path
  enable true
end

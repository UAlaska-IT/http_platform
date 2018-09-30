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

# Apache conf check ca_signed_cert? to switch cert path
www_server = www_server_name
plain_server = plain_server_name
aliases = generate_alias_pairs

var_map = {
  path_to_cert: path_to_ssl_cert,
  path_to_key: path_to_ssl_key
}

# Enable and harden TLS
apache_conf 'ssl-params' do
  source 'ssl-params.conf.erb'
  enable true
end

directory config_absolute_directory do
  owner 'root'
  group 'root'
  mode '0755'
end

# Common config for all HTTPS hosts
# We use template because apache_conf does not support variables
template 'Common Logic for HTTPS Hosts' do
  path config_absolute_directory + '/' + ssl_host_conf_name
  source 'ssl-host.conf.erb'
  variables var_map
  owner 'root'
  group 'root'
  mode '0644'
  # notifies :restart, "service[#{apache_service}]", :delayed
end

service apache_service do
  action :nothing
  subscribes :restart, 'template[Common Logic for HTTPS Hosts]', :delayed
end

# Default on Ubuntu
file '/etc/apache2/sites-available/default-ssl.conf' do
  action :delete
end

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
  enable true
end

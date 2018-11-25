# frozen_string_literal: true

tcb = 'http_platform'

# For apachectl fullstatus
package 'elinks' do
  only_if { node[tcb]['apache']['install_test_suite'] }
end

file path_to_elinks_config do
  content <<~CONTENT
    # This file is managed with Chef. For changes to persist, edit http_platform/recipes/apache.rb

    set connection.ssl.cert_verify = 0
  CONTENT
  only_if { node[tcb]['apache']['install_test_suite'] }
end

# We always include the basics
include_recipe 'apache2::default'
include_recipe 'apache2::mod_headers'
include_recipe 'apache2::mod_rewrite'
include_recipe 'apache2::mod_ssl'

include_recipe 'apache2::mod_status' if node[tcb]['apache']['install_test_suite']

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
host_names = generate_alias_pairs

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
  # This notifies does not compile because there is no service[apache2] declared by the apache2 cookbook
  # notifies :restart, "service[#{apache_service}]", :delayed
end

# This block creates an explicit declaration for the service created by installing the apache2 package
# Therefore client cookbooks can notify this service
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
  host_names host_names
  enable true
end

# HTTPS host
web_app 'ssl-site' do
  template 'site-ssl.conf.erb'
  host_names host_names
  enable true
end

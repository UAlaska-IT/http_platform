# frozen_string_literal: true

tcb = 'http_platform'

raise 'Must set node[\'http_platform\'][\'admin_email\']' unless node[tcb]['admin_email']

node.default['apache']['contact'] = node[tcb]['admin_email']
node.default['apache']['mod_ssl']['cipher_suite'] = http_cipher_suite

staple_error = node[tcb]['apache']['use_stapling'] != 'off' && use_self_signed_cert?
raise 'Cannot use stapling with an untrusted certificate' if staple_error

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

host_names = generate_alias_pairs
access_directories, access_files = access_directories_and_files

var_map = {
  access_directories: access_directories,
  access_files: access_files,
  cipher_suite: http_cipher_suite,
  path_to_cert: path_to_ssl_cert,
  path_to_key: path_to_private_key,
  path_to_dh_params: path_to_dh_params
}

# This block creates an explicit declaration for the service created by installing the apache2 package
# Therefore client cookbooks can notify this service
service apache_service do
  action :nothing
end

directory config_absolute_directory do
  owner 'root'
  group 'root'
  mode '0755'
end

ssl_conf = File.join(conf_available_directory, ssl_conf_name)

# Enable and harden TLS
# We use template because apache_conf does not support variables
template 'SSL Logic for HTTPS' do
  path ssl_conf
  source 'ssl-params.conf.erb'
  variables var_map
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, "service[#{apache_service}]", :delayed
end

link 'Link for SSL Conf' do
  target_file File.join(conf_enabled_directory, ssl_conf_name)
  to ssl_conf
  owner 'root'
  group 'root'
  notifies :restart, "service[#{apache_service}]", :delayed
end

# Common config for all HTTPS hosts
# We use template because apache_conf does not support variables
template 'Common Logic for HTTPS Hosts' do
  path File.join(config_absolute_directory, ssl_host_conf_name)
  source 'ssl-host.conf.erb'
  variables var_map
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, "service[#{apache_service}]", :delayed
end

conf_to_delete = [
  'default-ssl.conf' # Default on Ubuntu
]

conf_to_delete.each do |conf|
  file File.join(conf_available_directory, conf) do
    action :delete
    notifies :restart, "service[#{apache_service}]", :delayed
  end
  link File.join(conf_enabled_directory, conf) do
    action :delete
    notifies :restart, "service[#{apache_service}]", :delayed
  end
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

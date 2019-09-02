# frozen_string_literal: true

tcb = 'http_platform'

raise 'Must set node[\'http_platform\'][\'admin_email\']' unless node[tcb]['admin_email']

raise 'Cannot configure apache without configuring cert' unless node[tcb]['configure_cert']

node.default['apache']['contact'] = node[tcb]['admin_email']
node.default['apache']['mod_ssl']['cipher_suite'] = http_cipher_suite

# For apachectl fullstatus
package 'elinks' do
  only_if { node[tcb]['apache']['install_test_suite'] }
end

file path_to_elinks_config do
  content <<~CONTENT
    # This file is managed with Chef. For changes to persist, edit http_platform/recipes/_apache.rb

    set connection.ssl.cert_verify = 0
  CONTENT
  only_if { node[tcb]['apache']['install_test_suite'] }
end

# We always include the basics
apache2_install 'default_install'
apache2_module 'headers'
apache2_module 'rewrite'
apache2_module 'ssl'

apache2_module 'status' if node[tcb]['apache']['install_test_suite']

# Now include any extras
node[tcb]['apache']['extra_mods_to_install'].each do |name, _|
  apache2_module name
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
use_stapling =
  if node[tcb]['apache']['use_stapling'] && !use_self_signed_cert?
    'on'
  else
    'off'
  end

var_map = {
  access_directories: access_directories,
  access_files: access_files,
  cipher_suite: http_cipher_suite,
  path_to_cert: path_to_ssl_cert,
  path_to_key: path_to_ssl_key,
  path_to_dh_params: path_to_dh_params,
  use_stapling: use_stapling
}

# This block creates an explicit declaration for the service created by installing the apache2 package
# Therefore client cookbooks can notify this service
service apache_service do
  extend Apache2::Cookbook::Helpers
  service_name(lazy { apache_platform_service_name })
  supports restart: true, status: true, reload: true
  action :nothing
end

directory config_absolute_directory do
  mode '0755'
end

ssl_conf = File.join(conf_available_directory, ssl_conf_name)

# Enable and harden TLS
# We use template because apache_conf does not support variables
template 'SSL Logic for HTTPS' do
  path ssl_conf
  source 'ssl-params.conf.erb'
  variables var_map
  mode '0640'
  notifies :restart, "service[#{apache_service}]", :delayed
end

link 'Link for SSL Conf' do
  target_file File.join(conf_enabled_directory, ssl_conf_name)
  to ssl_conf
  notifies :restart, "service[#{apache_service}]", :delayed
end

# Common config for all HTTPS hosts
# We use template because apache_conf does not support variables
template 'Common Logic for HTTPS Hosts' do
  path File.join(config_absolute_directory, ssl_host_conf_name)
  source 'ssl-host.conf.erb'
  variables var_map
  mode '0640'
  notifies :restart, "service[#{apache_service}]", :delayed
end

conf_to_delete = [
  # Defaults on Ubuntu
  '000-default.conf',
  'default-ssl.conf'
]

conf_to_delete.each do |conf|
  file File.join(site_available_directory, conf) do
    action :delete
    notifies :restart, "service[#{apache_service}]", :delayed
  end
  link File.join(site_enabled_directory, conf) do
    action :delete
    notifies :restart, "service[#{apache_service}]", :delayed
  end
end

var_map = {
  host_names: host_names
}

# HTTP host, permanent redirect
template 'Default Host' do
  path File.join(site_available_directory, 'site-000.conf')
  source 'site-000.conf.erb'
  variables var_map
  mode '0640'
  notifies :restart, "service[#{apache_service}]", :delayed
end

link File.join(site_enabled_directory, 'site-000.conf') do
  to File.join(site_available_directory, 'site-000.conf')
  notifies :restart, "service[#{apache_service}]", :delayed
end

# HTTPS host
template 'SSL Host' do
  path File.join(site_available_directory, 'site-ssl.conf')
  source 'site-ssl.conf.erb'
  variables var_map
  mode '0640'
  notifies :restart, "service[#{apache_service}]", :delayed
end

link File.join(site_enabled_directory, 'site-ssl.conf') do
  to File.join(site_available_directory, 'site-ssl.conf')
  notifies :restart, "service[#{apache_service}]", :delayed
end

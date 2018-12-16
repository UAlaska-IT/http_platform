# frozen_string_literal: true

tcb = 'http_platform'

acme_error = !configure_server?
raise 'Cannot fetch Let\'s Encrypt certificate without a server configured' if acme_error

if node['platform_family'] == 'debian'
  apt_package 'software-properties-common'
  # apt_repository 'universe'
  apt_repository 'certbot' do
    uri 'ppa:certbot/certbot'
  end
else
  include_recipe 'yum-epel'
end

if configure_apache?
  package 'python-certbot-apache'
  bot_flag = 'apache'
elsif configure_nginx?
  package 'python-certbot-nginx'
  bot_flag = 'nginx'
elsif configure_webroot?
  package 'certbot'
  bot_flag = 'webroot'
elsif configure_standalone?
  package 'certbot'
  bot_flag = 'standalone'
end

command = if configure_standalone?
            "#{node[tcb]['cert']['standalone_stop_command']}\n"
          else
            ''
          end
command += "certbot --#{bot_flag} certonly -n --email #{cert_email} --agree-tos"
command += " -w #{node['http_platform']['www']['document_root']}" if configure_webroot?

names = generate_domain_names
names.each do |name|
  command += " -d #{name}"
end

command += "\n#{node[tcb]['cert']['standalone_start_command']}" if configure_standalone?

puts("CERTBOT COMMAND: #{command}")

file 'Certbot Record' do
  path '/opt/chef/run_record/certbot_command.txt'
  content command
end

# Certbot does not create new certs when hosts change, until the current certs expire
directory '/etc/letsencrypt' do
  recursive true
  action :nothing
  subscribes :delete, 'file[Certbot Record]', :immediate
end

# If certs exist and are not ready to renew then this does nothing
bash 'Get Lets Encrypt Certificate' do
  code command
  action :nothing if configure_standalone?
  subscribes :run, 'file[Certbot Record]', :delayed if configure_standalone?
  not_if { node[tcb]['cert']['kitchen_test'] }
end

# Certbot permissions are unsecure enough that daemons refuse to load them
# Copy them to the usual directory
remote_file path_to_lets_encrypt_cert do
  owner 'root'
  group 'root'
  mode '0644'
  source "file://#{path_to_lets_encrypt_cert_link}"
  # force_unlink
  # manage_symlink_source
end
remote_file path_to_lets_encrypt_key do
  owner 'root'
  group node[tcb]['cert']['owner_group']
  mode '0640'
  source "file://#{path_to_lets_encrypt_key_link}"
  # force_unlink
  # manage_symlink_source
end

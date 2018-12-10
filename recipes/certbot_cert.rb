# frozen_string_literal: true

tcb = 'http_platform'

acme_error = !configure_server?
raise 'Cannot fetch Let\'s Encrypt certificate without a server configured' if acme_error

if node['platform_family'] == 'debian'
  apt_package 'software-properties-common'
  apt_repository 'certbot' do
    uri 'ppa:certbot/certbot'
  end
else
  include_recipe 'yum-epel'
end

package 'python-certbot-apache'

command = "certbot --apache certonly -n --email #{cert_email} --agree-tos"
names = generate_domain_names
names.each do |name|
  command += " -d #{name}"
end

puts("CERTBOT COMMAND: #{command}")

bash 'Get Lets Encrypt Certificate' do
  code command
  action :nothing
end

file 'Certbot Record' do
  path '/opt/chef/run_record/certbot_command.txt'
  content command
  notifies :run, 'bash[Get Lets Encrypt Certificate]', :immediate
end

# Certbot permissions are weird; everything is world readable except for archive and live directories
# Works for us; give permissions to group by changing one directory
directory '/etc/letsencrypt/live' do
  owner 'root'
  group node[tcb]['cert']['owner_group']
  mode '0750'
end

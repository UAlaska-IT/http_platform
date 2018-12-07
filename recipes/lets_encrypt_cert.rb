# frozen_string_literal: true

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
  notifies :run, "bash[Get Lets Encrypt Certificate]", :immediate
end

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

command = 'certbot --apache certonly -n'
names = generate_alt_names
names.each do |name|
  command += " -d #{name}"
end

bash 'Get CA Certificate' do
  code command
  action :nothing
end

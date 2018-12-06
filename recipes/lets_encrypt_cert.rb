# frozen_string_literal: true

tcb = 'http_platform'

acme_error = !node[tcb]['configure_apache'] && node[tcb]['cert']['use_lets_encrypt_cert']
raise 'Cannot fetch Let\'s Encrypt certificate without Apache' if acme_error

if node[tcb]['cert']['use_lets_encrypt_cert']
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
end

# frozen_string_literal: true

tcb = 'http_platform'

openssl_x509_request path_to_ca_signed_request do
  owner 'root'
  group 'root'
  mode '0600'

  # Below must match the certificate
  common_name cert_common_name
  country node[tcb]['cert']['country']
  state node[tcb]['cert']['state']
  city node[tcb]['cert']['locale']
  org node[tcb]['cert']['organization']
  org_unit node[tcb]['cert']['org_unit']
  email cert_email

  key_file path_to_private_key
  # key_pass

  key_type 'rsa'
  # key_curve # default 'prime256v1'
  key_length node[tcb]['cert']['rsa_bits']
  notifies :run, 'bash[Get CA Certificate]', :delayed if node[tcb]['configure_apache']
end

if node[tcb]['configure_apache']
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

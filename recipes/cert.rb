# frozen_string_literal: true

tcb = 'http_platform'

raise 'node[\'http_platform\'][\'cert\'][\'organization\'] must be set' unless node[tcb]['cert']['organization']
raise 'node[\'http_platform\'][\'cert\'][\'org_unit\'] must be set' unless node[tcb]['cert']['org_unit']

# openssl_x509_certificate is not mutable, so becomes obsolete if anything changes
# This file must record all fields in the cert, super manual, boo!
cert_record = '/opt/chef/run_record/http_cert_record.txt'
key_record = '/opt/chef/run_record/http_key_record.txt'

file cert_record do
  content <<~CONTENT
    # ca_cert_file
    # ca_key_file
    # ca_key_pass
    # csr_file
    common_name: #{cert_common_name}
    subject_alt_name: #{generate_alt_names}
    country: #{node[tcb]['cert']['country']}
    state: #{node[tcb]['cert']['state']}
    city: #{node[tcb]['cert']['locale']}
    org: #{node[tcb]['cert']['organization']}
    org_unit: #{node[tcb]['cert']['org_unit']}
    email: #{cert_email}
    expire: #{node[tcb]['cert']['expiration_days']}
    # extensions

    key_file: #{path_to_private_key}
    # key_pass

    key_type: 'rsa'
    # key_curve # default 'prime256v1'
    key_length: #{node[tcb]['cert']['rsa_bits']}
  CONTENT
end

# Only delete private key if relevant parameter changes
file key_record do
  content <<~CONTENT
    key_length: #{node[tcb]['cert']['rsa_bits']}
  CONTENT
end

file path_to_self_signed_cert do
  action :nothing
  subscribes :delete, "file[#{cert_record}]", :immediate
end

file path_to_private_key do
  action :nothing
  subscribes :delete, "file[#{key_record}]", :immediate
end

openssl_x509_certificate path_to_self_signed_cert do
  owner 'root'
  group 'root'
  mode '0600'
  notifies :restart, "service[#{apache_service}]", :delayed if node[tcb]['configure_apache']
  # The fields below must match the file above!

  # ca_cert_file
  # ca_key_file
  # ca_key_pass
  # csr_file
  common_name cert_common_name
  subject_alt_name generate_alt_names
  country node[tcb]['cert']['country']
  state node[tcb]['cert']['state']
  city node[tcb]['cert']['locale']
  org node[tcb]['cert']['organization']
  org_unit node[tcb]['cert']['org_unit']
  email cert_email
  expire node[tcb]['cert']['expiration_days']
  # extensions

  key_file path_to_private_key
  # key_pass

  key_type 'rsa'
  # key_curve # default 'prime256v1'
  key_length node[tcb]['cert']['rsa_bits']
end

template 'DH configuration' do
  path path_to_dh_config
  source 'dh_config.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

# If any variables are added here, they must be added to the dh template to properly signal the script
bash 'Create DH parameters' do
  code "sudo openssl dhparam -out '#{path_to_dh_params}' #{node[tcb]['cert']['dh_param']['bits']}"
  action :nothing
  subscribes :run, 'template[DH configuration]', :immediate
  notifies :restart, "service[#{apache_service}]", :delayed if node[tcb]['configure_apache']
end

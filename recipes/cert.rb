# frozen_string_literal: true

tcb = 'http_platform'

cert_email =
  if node[tcb]['cert']['self_signed']['email'].nil?
    node[tcb]['admin_email']
  else
    node[tcb]['cert']['self_signed']['email']
  end

openssl_x509_certificate path_to_self_signed_cert do
  # ca_cert_file
  # ca_key_file
  # ca_key_pass
  # csr_file
  owner 'root'
  group 'root'
  mode '0600'
  common_name cert_common_name
  # subject_alt_name
  country node[tcb]['cert']['self_signed']['country']
  state node[tcb]['cert']['self_signed']['state']
  city node[tcb]['cert']['self_signed']['locale']
  org node[tcb]['cert']['self_signed']['organization']
  org_unit node[tcb]['cert']['self_signed']['org_unit']
  email cert_email
  expire node[tcb]['cert']['self_signed']['expiration_days']
  # extensions

  key_file path_to_self_signed_key
  # key_pass

  # key_type # default 'rsa'
  # key_curve # default 'prime256v1'
  key_length node[tcb]['cert']['self_signed']['rsa_bits']
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
end

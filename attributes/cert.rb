# frozen_string_literal: true

tcb = 'http_platform'

if node['platform_family'] == 'debian'
  default[tcb]['cert']['cert_public_directory'] = '/etc/ssl/certs'
  default[tcb]['cert']['cert_private_directory'] = '/etc/ssl/private'
elsif node['platform_family'] == 'rhel'
  default[tcb]['cert']['cert_public_directory'] = '/etc/pki/tls/certs'
  default[tcb]['cert']['cert_private_directory'] = '/etc/pki/tls/private'
else
  raise "Platform family not recognized: #{node['platform_family']}"
end

# Defaults to FQDN
default[tcb]['cert']['prefix'] = nil
default[tcb]['cert']['key_suffix'] = '_key.pem'

default[tcb]['cert']['ca_signed']['request_suffix'] = '_cert_ca_request.pem'
default[tcb]['cert']['ca_signed']['cert_public_suffix'] = '_cert_ca_signed.pem'

default[tcb]['cert']['self_signed']['cert_public_suffix'] = '_cert_self_signed.pem'

default[tcb]['cert']['expiration_days'] = 365
default[tcb]['cert']['rsa_bits'] = 2048

default[tcb]['cert']['country'] = 'US'
default[tcb]['cert']['state'] = 'Alaska'
default[tcb]['cert']['locale'] = 'Fairbanks'
default[tcb]['cert']['organization'] = 'fake_org'
default[tcb]['cert']['org_unit'] = 'fake_unit'
# Defaults to FQDN
default[tcb]['cert']['common_name'] = nil
# Defaults to admin_email
default[tcb]['cert']['email'] = nil

default[tcb]['cert']['dh_param']['dh_param_file_name'] = 'dh_param.pem'
default[tcb]['cert']['dh_param']['bits'] = 2048

# frozen_string_literal: true

tcb = 'http_platform'

if node['platform_family'] == 'debian'
  default[tcb]['cert']['cert_public_directory'] = '/etc/ssl/certs/'
  default[tcb]['cert']['cert_private_directory'] = '/etc/ssl/private/'
elsif node['platform_family'] == 'rhel'
  default[tcb]['cert']['cert_public_directory'] = '/etc/pki/tls/certs'
  default[tcb]['cert']['cert_private_directory'] = '/etc/pki/tls/private/'
else
  raise "Platform family not recognized: #{node['platform_family']}"
end

# Defaults to FQDN
default[tcb]['cert']['prefix'] = nil

default[tcb]['cert']['ca_signed']['cert_public_suffix'] = '_cert_ca_signed.pem'

default[tcb]['cert']['self_signed']['cert_public_suffix'] = '_cert_self_signed.pem'
default[tcb]['cert']['self_signed']['cert_private_suffix'] = '_key_self_signed.pem'

default[tcb]['cert']['self_signed']['expiration_days'] = 365
default[tcb]['cert']['self_signed']['rsa_bits'] = 2048

default[tcb]['cert']['self_signed']['country'] = 'US'
default[tcb]['cert']['self_signed']['state'] = 'Alaska'
default[tcb]['cert']['self_signed']['locale'] = 'Fairbanks'
default[tcb]['cert']['self_signed']['organization'] = 'fake_org'
default[tcb]['cert']['self_signed']['org_unit'] = 'fake_unit'
# Defaults to FQDN
default[tcb]['cert']['self_signed']['common_name'] = nil
# Defaults to admin_email
default[tcb]['cert']['self_signed']['email'] = nil

default[tcb]['cert']['dh_param']['dh_param_file_name'] = 'dh_param.pem'
default[tcb]['cert']['dh_param']['bits'] = 2048

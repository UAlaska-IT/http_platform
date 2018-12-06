# frozen_string_literal: true

tcb = 'http_platform'

default[tcb]['cert']['key_suffix'] = '_key.pem'

default[tcb]['cert']['ca_signed']['request_suffix'] = '_cert_ca_request.pem'
default[tcb]['cert']['ca_signed']['cert_public_suffix'] = '_cert_ca_signed.pem'

default[tcb]['cert']['self_signed']['cert_public_suffix'] = '_cert_self_signed.pem'

default[tcb]['cert']['expiration_days'] = 365
default[tcb]['cert']['rsa_bits'] = 2048

default[tcb]['cert']['country'] = 'US'
default[tcb]['cert']['state'] = 'Alaska'
default[tcb]['cert']['locale'] = 'Fairbanks'
# These must be set if the cert is being created
default[tcb]['cert']['organization'] = nil
default[tcb]['cert']['org_unit'] = nil
# Defaults to FQDN
default[tcb]['cert']['common_name'] = nil
# Defaults to admin_email
default[tcb]['cert']['email'] = nil

default[tcb]['cert']['dh_param']['dh_param_file_name'] = 'dh_param.pem'
default[tcb]['cert']['dh_param']['bits'] = 2048

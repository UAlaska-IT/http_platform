# frozen_string_literal: true

tcb = 'http_platform'

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

default[tcb]['cert']['dh_param']['bits'] = 2048

default[tcb]['cert']['vault_data_bag'] = 'certs' # The name of the vault data bag
# Defaults to fqdn
default[tcb]['cert']['vault_bag_item'] = nil # item inside the data bag (json file)
default[tcb]['cert']['vault_item_key'] = 'cert' # The key for password within the json object

# This will typically be nil because the generated CSR will be used to create the certificate
# However, a key will be manually placed on the system if this is non-nil, e.g. in kitchen
default[tcb]['key']['vault_item_key'] = nil # The key for password within the json object

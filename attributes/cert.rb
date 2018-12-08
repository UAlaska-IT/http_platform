# frozen_string_literal: true

tcb = 'http_platform'

default[tcb]['cert']['owner_group'] = 'root'

default[tcb]['cert']['expiration_days'] = 365
default[tcb]['cert']['rsa_bits'] = 2048
default[tcb]['cert']['dh_param']['bits'] = 2048

default[tcb]['cert']['country'] = 'US'
default[tcb]['cert']['state'] = 'Alaska'
default[tcb]['cert']['locale'] = 'Fairbanks'

default[tcb]['cert']['organization'] = nil
default[tcb]['cert']['org_unit'] = nil

default[tcb]['cert']['common_name'] = nil
default[tcb]['cert']['email'] = nil

default[tcb]['cert']['vault_data_bag'] = 'certs'
default[tcb]['cert']['vault_bag_item'] = nil
default[tcb]['cert']['vault_item_key'] = 'cert'

default[tcb]['key']['vault_item_key'] = nil

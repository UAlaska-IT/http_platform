# frozen_string_literal: true

tcb = 'http_platform'

default[tcb]['configure_firewall'] = true
default[tcb]['configure_cert'] = true
default[tcb]['configure_server'] = 'apache'

default[tcb]['configure_vault_cert'] = false
default[tcb]['configure_lets_encrypt_cert'] = false

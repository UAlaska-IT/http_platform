# frozen_string_literal: true

tcb = 'secure_apache'

default['nix_baseline']['hostname'] = 'web.calsev.net'
default['nix_baseline']['firewall']['enable_http'] = true
default['nix_baseline']['firewall']['enable_https'] = true

default[tcb]['configure_cert'] = true

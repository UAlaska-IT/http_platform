# frozen_string_literal: true

tcb = 'secure_apache'

default['nix_baseline']['hostname'] = 'web.calsev.net'

default[tcb]['configure_cert'] = true

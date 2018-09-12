# frozen_string_literal: true

tcb = 'secure_apache'

default[tcb]['firewall']['enable_http'] = true
default[tcb]['firewall']['enable_https'] = true

# frozen_string_literal: true

tcb = 'http_platform'

include_recipe "#{tcb}::local_cert" if node[tcb]['configure_cert']

invalid_config = configure_apache? && !node[tcb]['configure_cert']
raise 'Cannot configure apache without configuring cert' if invalid_config

include_recipe "#{tcb}::firewall" if node[tcb]['configure_firewall']

include_recipe "#{tcb}::apache" if configure_apache?

include_recipe "#{tcb}::certbot_cert" if node[tcb]['configure_lets_encrypt_cert']

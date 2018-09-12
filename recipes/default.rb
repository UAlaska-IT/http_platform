# frozen_string_literal: true

tcb = 'secure_apache'

include_recipe 'nix_baseline::default'

include_recipe "#{tcb}::firewall" if node['nix_baseline']['configure_firewall']

include_recipe "#{tcb}::cert" if node[tcb]['configure_cert'] # Must be after hostname

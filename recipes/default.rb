# frozen_string_literal: true

tcb = 'http_platform'

include_recipe 'nix_baseline::default'

include_recipe "#{tcb}::firewall" if node['nix_baseline']['configure_firewall'] # We defer to baseline firewall gate

include_recipe "#{tcb}::cert" if node[tcb]['configure_cert'] # Must be after hostname

include_recipe "#{tcb}::apache" if node[tcb]['configure_apache']

# frozen_string_literal: true

tcb = 'secure_apache'

include_recipe 'nix_baseline::default'

include_recipe "#{tcb}::cert" if node[tcb]['configure_cert'] # Must be after hostname

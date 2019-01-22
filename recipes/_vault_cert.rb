# frozen_string_literal: true

tcb = 'http_platform'

bag = node[tcb]['cert']['vault_data_bag']
item = node[tcb]['cert']['vault_bag_item'] || node['fqdn']
key = node[tcb]['cert']['vault_item_key']

file path_to_vault_cert do
  # must be lazy because hostname may change!
  content lazy { vault_secret(bag, item, key) } # rubocop:disable Lint/AmbiguousBlockAssociation
  mode '0644'
end

key_key = node[TCB]['key']['vault_item_key']

file path_to_vault_key do
  # must be lazy because hostname may change!
  content lazy { vault_secret(bag, item, key_key) } # rubocop:disable Lint/AmbiguousBlockAssociation
  sensitive true
  owner 'root'
  group node[tcb]['cert']['owner_group']
  mode '0640'
  only_if { key_key }
end

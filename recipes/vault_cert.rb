# frozen_string_literal: true

tcb = 'http_platform'

bag = node[tcb]['cert']['vault_data_bag']
item = node[tcb]['cert']['vault_bag_item'] || node['fqdn']
key = node[tcb]['cert']['vault_item_key']
cert = vault_secret(bag, item, key)

file path_to_vault_cert do
  content cert
end

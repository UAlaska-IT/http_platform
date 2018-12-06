# frozen_string_literal: true

tcb = 'http_platform'

bag_item = if node[tcb]['cert']['vault_bag_item']
             node[tcb]['cert']['vault_bag_item']
           else
             node['fqdn']
           end
bag = node[tcb]['cert']['vault_data_bag']
item = node[tcb]['cert']['vault_bag_item']
key = node[tcb]['cert']['vault_item_key']
cert = vault_secret(bag, item, key)

file path_to_vault_cert do
  content cert
end

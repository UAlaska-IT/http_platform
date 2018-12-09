# frozen_string_literal: true

tcb = 'http_platform'

include_recipe 'firewall::default'

firewall_rule 'Allow HTTP' do
  port 80
  protocol :tcp
  position 1
  command :allow
  only_if { node[tcb]['firewall']['enable_http'] }
end

firewall_rule 'Allow HTTPS' do
  port 443
  protocol :tcp
  position 1
  command :allow
end

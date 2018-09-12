# frozen_string_literal: true

tcb = 'secure_apache'

firewall_rule 'http' do
  port 80
  protocol :tcp
  position 1
  command :allow
  only_if { node[tcb]['firewall']['enable_http'] }
end

firewall_rule 'https' do
  port 443
  protocol :tcp
  position 1
  command :allow
  only_if { node[tcb]['firewall']['enable_https'] }
end

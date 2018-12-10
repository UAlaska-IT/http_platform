# frozen_string_literal: true

tcb = 'http_platform'

# TODO: Nginx recipe
raise 'Currently only Apache server is supported' unless configure_apache?

include_recipe "#{tcb}::_apache" if configure_apache?

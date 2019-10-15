# frozen_string_literal: true

require_relative '../helpers'

node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

describe file(File.join(sites_available_dir(node), 'ssl-site.conf')) do
  ['www.funny.business', 'funny.business', 'www.me.also', 'me.also'].each do |host|
    its(:content) { should match "ServerName #{host}" }
  end
  its(:content) { should_not match(/www\.funny\.business\.error\.log/) }
  its(:content) { should match 'funny\.business\.error\.log' }
  # its(:content) { should_not match(/www\.localhost\.error\.log/) }
  # its(:content) { should match 'localhost\.error\.log' }
  its(:content) { should_not match(/www\.me\.also\.error\.log/) }
  its(:content) { should match 'me\.also\.error\.log' }

  its(:content) { should_not match(/www\.funny\.business\.access\.log/) }
  its(:content) { should match 'funny\.business\.access\.log combined\s+LogLevel warn' }
  # its(:content) { should_not match(/www\.localhost\.access\.log/) }
  # its(:content) { should match 'localhost\.access\.log combined\s+LogLevel warn' }
  its(:content) { should_not match(/www\.me\.also\.access\.log/) }
  its(:content) { should match 'me\.also\.access\.log combined\s+LogLevel info' }
end

describe file(File.join(sites_available_dir(node), '000-site.conf')) do
  its(:content) { should match 'ServerName www.funny.business\s+Redirect permanent "/" "https://www.funny.business/"' }
  its(:content) { should match 'ServerName funny.business\s+Redirect permanent "/" "https://funny.business/"' }
  its(:content) { should match 'ServerName www.me.also\s+Redirect permanent "/" "https://www.me.also/"' }
  its(:content) { should match 'ServerName me.also\s+Redirect permanent "/" "https://me.also/"' }
end

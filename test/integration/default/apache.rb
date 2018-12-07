# frozen_string_literal: true

require_relative '../helpers'

node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

if node['platform_family'] == 'debian'
  conf_root_dir = '/etc/apache2'
  module_command = 'apache2ctl'
elsif node['platform_family'] == 'rhel'
  conf_root_dir = '/etc/httpd'
  module_command = 'httpd'
else
  raise "Platform family not recognized: #{node['platform_family']}"
end

conf_d_dir = File.join(conf_root_dir, 'conf.d')
conf_available_dir = File.join(conf_root_dir, 'conf-available')
conf_enabled_dir = File.join(conf_root_dir, 'conf-enabled')
sites_available_dir = File.join(conf_root_dir, 'sites-available')
sites_enabled_dir = File.join(conf_root_dir, 'sites-enabled')

describe package('elinks') do
  it { should be_installed }
end

path_to_elinks_config = if node['platform_family'] == 'debian'
                          '/etc/elinks/elinks.conf'
                        else
                          '/etc/elinks.conf'
                        end

describe file(path_to_elinks_config) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content) { should match 'set connection.ssl.cert_verify = 0' }
end

describe package(apache_service(node)) do
  it { should be_installed }
  its(:version) { should match(/^2\.4/) }
end

describe service(apache_service(node)) do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe bash("#{module_command} -M") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match 'headers_module' }
  its(:stdout) { should match 'rewrite_module' }
  its(:stdout) { should match 'ssl_module' }
  its(:stdout) { should match 'status_module' }
  its(:stdout) { should match 'lua_module' }
end

describe file('/var/www/html/index.html') do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content) { should match 'Welcome to Apache' }
end

['', '/'].each do |page|
  describe http('http://localhost:80' + page) do
    its(:status) { should cmp 301 }
    its(:body) { should match('https://www.funny.business') }
  end

  describe http('https://localhost:443' + page, ssl_verify: false) do
    its(:status) { should cmp 200 }
    its(:body) { should match('Now make yourself a website:\)') }
  end
end

describe http('https://localhost:443/index.html', ssl_verify: false) do
  its(:status) { should cmp 200 }
end

describe http('https://localhost:443/not_a_page', ssl_verify: false) do
  its(:status) { should cmp 404 }
  its(:body) { should match('404_kitten.php') }
end

describe http('https://localhost:443/old_site', ssl_verify: false) do
  its(:status) { should cmp 302 }
  its(:body) { should match('/new_site') }
end

if node['platform_family'] == 'debian' # CentOS ignores conf directive to not validate certificate
  describe bash('elinks -dump https://localhost') do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }
    its(:stdout) { should match 'Now make yourself a website:\)' }
  end
end

describe apache_conf do
  its('AllowOverride') { should eq ['None'] }
  its('Listen') { should match ['*:80', '*:443'] }
end

describe file(File.join(conf_available_dir, 'ssl-params.conf')) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  if node['platform_family'] == 'debian'
    its(:content) { should match "SSLOpenSSLConfCmd DHParameters #{path_to_dh_params(node)}" }
    # its(:content) { should match 'RedirectMatch 404 ".*"' }
  end
end

describe apache_conf(File.join(conf_available_dir, 'ssl-params.conf')) do
  its('SSLProtocol') { should eq ['All -SSLv2 -SSLv3 -TLSv1 -TLSv1.1'] }
  its('SSLCipherSuite') { should_not match(/NULL/) }
  its('SSLCipherSuite') { should_not match(/CBC/) }
  its('SSLCipherSuite') { should_not match(/SHA:/) }
  its('SSLInsecureRenegotiation') { should eq ['off'] }
end

describe file(File.join(conf_enabled_dir, 'ssl-params.conf')) do
  it { should exist }
  it { should be_symlink }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:link_path) { should eq File.join(conf_available_dir, 'ssl-params.conf') }
end

describe file(conf_d_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_mode 0o755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file(File.join(conf_d_dir, 'ssl-host.conf')) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content) { should match 'ServerAdmin fake-it@make-it' }
  its(:content) { should match 'DocumentRoot /var/www/html' }
  its(:content) { should match 'SSLEngine on' }
  its(:content) { should match '# Site owners are a pain' }
  its(:content) { should match 'Redirect /old_site /new_site' }
  its(:content) { should match 'RewriteEngine on' }
  its(:content) { should match 'RewriteRule /url_of_page\(\.\*\) /path_to_file\$1 \[L,NC\]' }
  its(:content) { should match '<Directory />\s+Require all granted' }
  its(:content) { should match 'ErrorDocument 404 404_kitten.php' }
  its(:content) { should match 'SSLOptions \+StdEnvVars' }
  its(:content) { should match 'SetHandler application/x-httpd-php' }
end

describe file(File.join(conf_available_dir, 'default-ssl.conf')) do
  it { should_not exist }
end

describe file(File.join(conf_enabled_dir, 'default-ssl.conf')) do
  it { should_not exist }
end

describe file(File.join(sites_available_dir, '000-site.conf')) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }

  its(:content) { should match 'ServerName www.funny.business\s+Redirect permanent "/" "https://www.funny.business/"' }
  its(:content) { should match 'ServerName funny.business\s+Redirect permanent "/" "https://funny.business/"' }
  its(:content) { should match 'ServerName www.me.also\s+Redirect permanent "/" "https://www.me.also/"' }
  its(:content) { should match 'ServerName me.also\s+Redirect permanent "/" "https://me.also/"' }
end

describe file(File.join(sites_available_dir, 'ssl-site.conf')) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }

  ['www.funny.business', 'funny.business', 'www.me.also', 'me.also'].each do |host|
    its(:content) { should match "ServerName #{host}" }
  end
  its(:content) { should_not match(/www\.funny\.business.error\.log/) }
  its(:content) { should match 'funny\.business.error\.log' }
  its(:content) { should_not match(/www\.me\.also.error\.log/) }
  its(:content) { should match 'me\.also.error\.log' }

  its(:content) { should_not match(/www\.funny\.business.access\.log/) }
  its(:content) { should match 'funny\.business.access\.log combined\s+LogLevel warn' }
  its(:content) { should_not match(/www\.me\.also.access\.log/) }
  its(:content) { should match 'me\.also.access\.log combined\s+LogLevel info' }

  its(:content) { should match 'Include conf.d/ssl-host.conf' }
end

describe file(File.join(sites_enabled_dir, '000-site.conf')) do
  it { should exist }
  it { should be_symlink }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:link_path) { should eq File.join(sites_available_dir, '000-site.conf') }
end

describe file(File.join(sites_enabled_dir, 'ssl-site.conf')) do
  it { should exist }
  it { should be_symlink }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:link_path) { should eq File.join(sites_available_dir, 'ssl-site.conf') }
end

describe bash('apachectl configtest') do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should match 'Syntax OK' } # Yep, output is on stderr
  its(:stdout) { should eq '' }
end

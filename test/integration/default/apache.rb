# frozen_string_literal: true

require_relative '../helpers'

node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

if node['platform_family'] == 'debian'
  module_command = 'apache2ctl'
elsif node['platform_family'] == 'rhel'
  module_command = 'httpd'
else
  raise "Platform family not recognized: #{node['platform_family']}"
end

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

index_content = 'Now make yourself a website:\)'

pages = [
  {
    page: '',
    status: 200,
    content: index_content
  },
  {
    page: '/',
    status: 200,
    content: index_content
  },
  {
    page: '/index.html',
    status: 200,
    content: index_content
  },
  {
    page: '/old_site',
    status: 302,
    content: '/new_site'
  },
  {
    page: '/not_a_page',
    status: 404,
    content: '404_kitten.php'
  }
]

pages.each do |page|
  describe http("http://localhost#{page[:page]}") do
    its(:status) { should cmp 301 }
    its(:body) { should match('https://') }
  end
end

pages.each do |page|
  describe http("https://localhost#{page[:page]}", ssl_verify: false) do
    its(:status) { should cmp page[:status] }
    its(:body) { should match(page[:content]) }
  end
end

if node['platform_family'] == 'debian' # CentOS ignores conf directive to not validate certificate
  pages.each do |page|
    describe bash("elinks -dump https://localhost#{page[:page]}") do
      its(:exit_status) { should eq 0 }
      its(:stderr) { should eq '' }
      # elinks is not following redirect?
      its(:stdout) { should match page[:content] } unless page[:status] == 302
    end
  end
end

describe apache_conf do
  its('AllowOverride') { should eq ['None'] }
  its('Listen') { should match ['80', '443'] }
end

describe file(File.join(path_to_conf_available_dir(node), 'ssl-params.conf')) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o640 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  if node['platform_family'] == 'debian'
    its(:content) { should match "SSLOpenSSLConfCmd DHParameters #{path_to_dh_params(node)}" }
    # its(:content) { should match 'RedirectMatch 404 ".*"' }
  end
end

describe apache_conf(File.join(path_to_conf_available_dir(node), 'ssl-params.conf')) do
  its('SSLProtocol') { should eq ['All -SSLv2 -SSLv3 -TLSv1 -TLSv1.1'] }
  its('SSLCipherSuite') { should_not match(/NULL/) }
  its('SSLCipherSuite') { should_not match(/CBC/) }
  its('SSLCipherSuite') { should_not match(/SHA:/) }
end

describe file(File.join(conf_enabled_dir(node), 'ssl-params.conf')) do
  it { should exist }
  it { should be_symlink }
  it { should be_mode 0o640 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:link_path) { should eq File.join(path_to_conf_available_dir(node), 'ssl-params.conf') }
end

describe file(conf_available_dir(node)) do
  it { should exist }
  it { should be_directory }
  it { should be_mode 0o755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file(File.join(conf_available_dir(node), 'ssl-host.conf')) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o640 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content) { should match 'ServerAdmin ua-oit-se@alaska.edu' }
  its(:content) { should match 'DocumentRoot /var/www/html' }
  its(:content) { should match 'SSLEngine on' }
  its(:content) { should match 'Header always set Referrer-Policy "no-referrer"' }
  its(:content) { should match 'Header always set X-Frame-Options DENY' }
  its(:content) { should match 'Header always set X-Content-Type-Options nosniff' }
  its(:content) { should match 'Header always set X-XSS-Protection "1; mode=block"' }
  its(:content) { should match 'Header always set Content-Security-Policy "base-uri \'none\'"' }
  its(:content) { should match '# Site owners are a pain' }
  its(:content) { should match 'RedirectMatch /old_site /new_site' }
  its(:content) { should match 'RewriteEngine on' }
  its(:content) { should match 'RewriteRule /url_of_page\(\.\*\) /path_to_file\$1 \[L,NC\]' }
  its(:content) { should match '<Directory />\s+<Files />\s+Require all granted' }
  its(:content) { should match '<Directory />\s+<Files index.html>\s+Require all granted' }
  its(:content) { should match '<Directory /stuff>\s+Require all granted' }
  its(:content) { should match 'ErrorDocument 404 404_kitten.php' }
  its(:content) { should match 'SSLOptions \+StdEnvVars' }
end

describe file(File.join(path_to_conf_available_dir(node), 'default-ssl.conf')) do
  it { should_not exist }
end

describe file(File.join(conf_enabled_dir(node), 'default-ssl.conf')) do
  it { should_not exist }
end

describe file(File.join(sites_available_dir(node), '000-site.conf')) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o640 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file(File.join(sites_available_dir(node), 'ssl-site.conf')) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o640 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content) { should match 'Include conf-available/ssl-host.conf' }
end

describe file(File.join(sites_enabled_dir(node), '000-site.conf')) do
  it { should exist }
  it { should be_symlink }
  it { should be_mode 0o640 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:link_path) { should eq File.join(sites_available_dir(node), '000-site.conf') }
end

describe file(File.join(sites_enabled_dir(node), 'ssl-site.conf')) do
  it { should exist }
  it { should be_symlink }
  it { should be_mode 0o640 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:link_path) { should eq File.join(sites_available_dir(node), 'ssl-site.conf') }
end

describe bash('apachectl configtest') do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should match 'Syntax OK' } # Yep, output is on stderr
  its(:stdout) { should eq '' }
end

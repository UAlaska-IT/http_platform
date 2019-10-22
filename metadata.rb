# frozen_string_literal: true

name 'http_platform'
maintainer 'OIT Systems Engineering'
maintainer_email 'ua-oit-se@alaska.edu'
license 'MIT'
description 'Installs/configures an HTTPS server'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

git_url = 'https://github.com/ualaska-it/http_platform'
source_url git_url if respond_to?(:source_url)
issues_url "#{git_url}/issues" if respond_to?(:issues_url)

version '2.3.0'

supports 'ubuntu', '>= 16.0'
supports 'debian', '>= 9.0'
supports 'redhat', '>= 6.0'
supports 'centos', '>= 6.0'
supports 'oracle', '>= 6.0'
# supports 'fedora'
# supports 'amazon'
# supports 'suse'
# supports 'opensuse'

chef_version '>= 14.0' if respond_to?(:chef_version)

depends 'apache2', '>= 6.0'
depends 'apt'
depends 'chef_run_recorder'
depends 'chef-vault'
depends 'firewall'
depends 'idempotence_file'
depends 'yum-epel'

# frozen_string_literal: true

name 'test_harness'
maintainer 'OIT Systems Engineering'
maintainer_email 'ua-oit-se@alaska.edu'
license 'MIT'
description 'Test fixture for the http_platform cookbook'

git_url = 'https://github.com/ualaska-it/http_platform'
source_url git_url
issues_url "#{git_url}/issues"

version '1.0.0'

supports 'ubuntu', '>= 16.0'
supports 'centos', '>= 7.0'

chef_version '>= 14.0.0'

depends 'http_platform'

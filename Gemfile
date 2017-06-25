source 'https://rubygems.org'

if ENV['ZUUL_REF']
  git_path = 'file:///opt/git/openstack-infra/puppet-openstack_infra_spec_helper'
  git_ref = ENV['ZUUL_REF']
else
  git_path = 'https://git.openstack.org/openstack-infra/puppet-openstack_infra_spec_helper'
  git_ref = 'master'
end

group :development, :test, :system_tests do
  gem 'puppet-openstack_infra_spec_helper',
      :git     => git_path, :ref => git_ref,
      :require => false
end

# vim:ft=ruby

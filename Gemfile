source 'https://rubygems.org'

group :development, :unit_tests do
  gem 'puppetlabs_spec_helper', :require => false
  gem 'rspec-puppet', '~> 2.1.0', :require => false

  gem 'json'
  gem 'webmock'
end

group :system_tests do
  gem 'beaker-rspec', :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby

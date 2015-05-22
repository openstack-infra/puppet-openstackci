source 'https://rubygems.org'

group :development, :test do
  gem 'puppetlabs_spec_helper', :require => false
  gem 'rspec-puppet', '~> 2.1.0', :require => false

  gem 'beaker-rspec', '~> 2.2.4', :require => false
  gem 'json'
  gem 'webmock'
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby

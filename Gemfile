source 'https://rubygems.org'

group :development, :unit_tests do
  gem 'puppetlabs_spec_helper', :require => false
  gem 'rspec-puppet', '~> 2.1.0', :require => false

  gem 'json'
  gem 'webmock'
end

group :system_tests do
  gem 'beaker-rspec', :require => false
  # Workaround for fog-google requiring ruby 2.0 on latest version
  # https://github.com/fog/fog-google/commit/a66b16fa7c2373f9c8be2e80bc942ad8d13ece3f
  gem 'fog-google', '0.1.0'
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby

require 'beaker-rspec'
require 'tmpdir'
require 'json'

hosts.each do |host|

  install_puppet

  on host, "mkdir -p #{host['distmoduledir']}"
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  modname = JSON.parse(open('metadata.json').read)['name'].split('-')[1]

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    hosts.each do |host|

      # install git
      install_package host, 'git'

      # If we are running in CI, we expect the modules to have been
      # installed by the test prep.  If not, we need to install the
      # modules ourselves.
      if Dir.entries('/etc/puppet/modules/').size == 2
        Dir.mktmpdir { |dir|
          shell("git clone https://git.openstack.org/openstack-infra/system-config #{dir}/system-config")
          shell("#{dir}/system-config/tools/install_modules.sh")
        }
        # Install the module being tested
        puppet_module_install(:source => proj_root, :module_name => modname)
      end

      # List modules installed to help with debugging
      on hosts[0], puppet('module','list'), { :acceptable_exit_codes => 0 }
    end
  end
end

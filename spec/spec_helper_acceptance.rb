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
      on host, "ls /etc/puppet/modules" do |r|
        if r.stdout == ""
          dir = host.tmpdir('system-config')
          on host, "git clone https://git.openstack.org/openstack-infra/system-config #{dir}/system-config"
          on host, "#{dir}/system-config/install_modules.sh"

          # Delete and then copy the module being tested in to place.
          on host, "rm -fr /etc/puppet/modules/#{modname}"
          copy_module_to(host, :source => proj_root, :module_name => modname)
          on host, "rm -fr #{dir}"
        end
      end

      # List modules installed to help with debugging
      on host, puppet('module','list'), { :acceptable_exit_codes => 0 }
    end
  end
end

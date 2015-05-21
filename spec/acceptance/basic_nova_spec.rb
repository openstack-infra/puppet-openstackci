require 'spec_helper_acceptance'

describe 'basic nova' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
        include openstackci::logserver
        class { '::openstackci::logserver':
           domain => 'foo',
           jenkins_ssh_key => 'foo',
           swift_authurl => '',
           swift_user => '',
           swift_key => '',
           swift_tenant_name => '',
           swift_region_name => '',
           swift_default_container => '',
        }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(80) do
      it { is_expected.to be_listening.with('tcp') }
    end

  end
end

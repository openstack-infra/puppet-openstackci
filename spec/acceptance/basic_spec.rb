require 'spec_helper_acceptance'

describe 'basic openstackci' do

  if fact('osfamily') == 'Debian'

    context 'default parameters' do

      it 'should work with no errors' do

        base_path = File.dirname(__FILE__)
        pp_path = File.join(base_path, 'fixtures', 'default.pp')
        pp = File.read(pp_path)

        # Run it twice and test for idempotency
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true)
      end

    end

    context 'installation of packages' do

      describe package('apache2') do
        it { should be_installed }
      end

    end

    context 'files and directories' do

      describe file('/etc/os_loganalyze/wsgi.conf') do
        it { should be_file }
        it { should be_owned_by 'root' }
        it { should be_mode 440 }
      end

    end

  end

end
